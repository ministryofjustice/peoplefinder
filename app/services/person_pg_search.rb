class PersonPgSearch
  SIMILARITY_THRESHOLD = 0.25
  MAX_RESULTS = 100

  attr_reader :query, :results

  def initialize(query, results)
    @query = clean_query(query)
    @email_query = query.strip.downcase
    @results = results
  end

  def perform_search
    if query.present? && !email_found
      do_searches
    end
    results
  end

  # Lightweight struct that mimics the OpenSearch hit interface used by es_highlighter.
  class Hit
    attr_reader :highlight

    def initialize(person, pattern)
      @highlight = Highlight.new(person, pattern)
    end

    class Highlight
      FIELDS = %i[name role_and_group current_project email].freeze

      def initialize(person, pattern)
        @person = person
        @pattern = pattern
      end

      FIELDS.each do |field|
        define_method(field) do
          return nil unless @pattern

          value = @person.send(field).to_s
          return nil unless value.match?(@pattern)

          [value.gsub(@pattern) { |m| %(<span class="es-highlight">#{m}</span>) }]
        end
      end
    end
  end

  def self.synonyms_for(word)
    synonyms[word.downcase] || []
  end

  class << self
  private

    def synonyms
      @synonyms ||= load_synonyms
    end

    def load_synonyms
      hash = Hash.new { |h, k| h[k] = [] }
      File.readlines(Rails.root.join("config/initializers/name_synonyms.csv"), chomp: true).each do |line|
        next if line.blank?

        words = line.split(",").map(&:strip).reject(&:blank?)
        next if words.size < 2

        words.each { |w| hash[w.downcase].concat((words - [w]).map(&:downcase)) }
      end
      hash
    end
  end

private

  def email_found
    person = Person.find_by(email: @email_query)
    if person
      @results.set = [person]
      @results.hit_builder = email_hit_builder
      @results.contains_exact_match = true
    end
    @results.present?
  end

  def do_searches
    words = query_words
    expanded = expand_with_synonyms(words)

    @results.set = pg_search(words, expanded)
    @results.hit_builder = build_hit_builder(expanded)
    @results.contains_exact_match = exact_match_exists?
  end

  def exact_match_exists?
    if single_word_query?
      @results.set.present?
    else
      @results.set.any? { |p| p.name.casecmp(@query).zero? || any_partial_match?(p) }
    end
  end

  def single_word_query?
    !@query[/\s/]
  end

  def any_partial_match?(person)
    %i[description role_and_group location current_project].any? do |field|
      person.send(field)&.match?(/#{Regexp.escape(@query)}/i)
    end
  end

  def email_hit_builder
    pattern = Regexp.new(Regexp.escape(@email_query), Regexp::IGNORECASE)
    ->(person) { Hit.new(person, pattern) }
  end

  def build_hit_builder(words)
    return nil if words.empty?

    pattern = Regexp.new(words.map { |w| "\\b#{Regexp.escape(w)}\\b" }.join("|"), Regexp::IGNORECASE)
    ->(person) { Hit.new(person, pattern) }
  end

  # words        — original query terms, used for LIKE (substring) + exact matching
  # all_terms    — words + synonyms, synonyms used for exact matching only
  def pg_search(words, all_terms = words)
    return [] if words.empty?

    like_terms = words.map { |term| "%#{escape_like(term)}%" }
    ph_all  = placeholders(all_terms.size)
    ph_like = placeholders(words.size)

    sql = <<~SQL
      SELECT p.*,
        (
          CASE WHEN lower(p.given_name) = ANY(ARRAY[#{ph_all}]) THEN 20
               WHEN lower(p.given_name) LIKE ANY(ARRAY[#{ph_like}]) THEN 12
               ELSE 0 END +
          CASE WHEN lower(p.surname) = ANY(ARRAY[#{ph_all}]) THEN 20
               WHEN lower(p.surname) LIKE ANY(ARRAY[#{ph_like}]) THEN 12
               ELSE 0 END +
          similarity(
            lower(COALESCE(p.given_name, '') || ' ' || COALESCE(p.surname, '')),
            lower(?)
          ) * 8 +
          CASE WHEN EXISTS (
            SELECT 1 FROM memberships m JOIN groups g ON g.id = m.group_id
            WHERE m.person_id = p.id AND (
              lower(g.name) LIKE ANY(ARRAY[#{ph_like}])
              OR lower(COALESCE(m.role, '')) LIKE ANY(ARRAY[#{ph_like}])
            )
          ) THEN 6 ELSE 0 END +
          CASE WHEN lower(COALESCE(p.current_project, '')) LIKE ANY(ARRAY[#{ph_like}]) THEN 4 ELSE 0 END +
          CASE WHEN lower(
            COALESCE(p.location_in_building, '') || ' ' ||
            COALESCE(p.building, '') || ' ' ||
            COALESCE(p.city, '')
          ) LIKE ANY(ARRAY[#{ph_like}]) THEN 4 ELSE 0 END +
          CASE WHEN lower(COALESCE(p.description, '')) LIKE ANY(ARRAY[#{ph_like}]) THEN 2 ELSE 0 END
        ) AS search_rank
      FROM people p
      WHERE (
        lower(p.given_name) = ANY(ARRAY[#{ph_all}])
        OR lower(p.surname) = ANY(ARRAY[#{ph_all}])
        OR lower(p.given_name) LIKE ANY(ARRAY[#{ph_like}])
        OR lower(p.surname) LIKE ANY(ARRAY[#{ph_like}])
        OR similarity(lower(COALESCE(p.given_name, '')), lower(?)) > ?
        OR similarity(lower(COALESCE(p.surname, '')), lower(?)) > ?
        OR similarity(
          lower(COALESCE(p.given_name, '') || ' ' || COALESCE(p.surname, '')),
          lower(?)
        ) > ?
        OR EXISTS (
          SELECT 1 FROM memberships m JOIN groups g ON g.id = m.group_id
          WHERE m.person_id = p.id AND (
            lower(g.name) LIKE ANY(ARRAY[#{ph_like}])
            OR lower(COALESCE(m.role, '')) LIKE ANY(ARRAY[#{ph_like}])
          )
        )
        OR lower(COALESCE(p.current_project, '')) LIKE ANY(ARRAY[#{ph_like}])
        OR lower(
          COALESCE(p.location_in_building, '') || ' ' ||
          COALESCE(p.building, '') || ' ' ||
          COALESCE(p.city, '')
        ) LIKE ANY(ARRAY[#{ph_like}])
        OR lower(COALESCE(p.description, '')) LIKE ANY(ARRAY[#{ph_like}])
      )
      ORDER BY search_rank DESC, p.surname ASC, p.given_name ASC
      LIMIT 100 /* MAX_RESULTS */
    SQL

    thresh = SIMILARITY_THRESHOLD.to_f
    binds = [
      # SELECT scoring
      *all_terms,   # given_name =
      *like_terms,  # given_name LIKE
      *all_terms,   # surname =
      *like_terms,  # surname LIKE
      @query,       # full-name similarity * 8
      *like_terms,  # EXISTS: group name
      *like_terms,  # EXISTS: role
      *like_terms,  # current_project
      *like_terms,  # location
      *like_terms,  # description
      # WHERE clause
      *all_terms,   # given_name =
      *all_terms,   # surname =
      *like_terms,  # given_name LIKE
      *like_terms,  # surname LIKE
      @query,
      thresh,       # given_name similarity
      @query,
      thresh,       # surname similarity
      @query,
      thresh,       # full-name similarity
      *like_terms,  # EXISTS: group name
      *like_terms,  # EXISTS: role
      *like_terms,  # current_project
      *like_terms,  # location
      *like_terms,  # description
    ]

    Person.find_by_sql([sql, *binds])
  end

  def placeholders(num)
    (["?"] * Integer(num)).join(", ")
  end

  def escape_like(str)
    str.gsub(/[\\%_]/) { |c| "\\#{c}" }
  end

  def query_words
    @query.downcase.split(/\s+/).reject(&:blank?)
  end

  def expand_with_synonyms(words)
    (words + words.flat_map { |w| self.class.synonyms_for(w) }).uniq
  end

  def clean_query(query)
    query.gsub(/[^[[:alnum:]]'']/, " ").tr(",", " ").squeeze(" ").strip
  end
end
