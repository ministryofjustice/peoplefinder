class PersonSearch
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

    @results.set = pg_search(expanded)
    @results.hit_builder = build_hit_builder(words)
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

    pattern = Regexp.new(words.map { |w| Regexp.escape(w) }.join("|"), Regexp::IGNORECASE)
    ->(person) { Hit.new(person, pattern) }
  end

  def pg_search(terms)
    return [] if terms.empty?

    like_terms = terms.map { |t| "%#{escape_like(t)}%" }
    n = terms.size
    ep = (["?"] * n).join(", ")  # exact placeholders
    lp = (["?"] * n).join(", ")  # like placeholders

    sql = <<~SQL
      SELECT p.*,
        (
          CASE WHEN lower(p.given_name) = ANY(ARRAY[#{ep}]) THEN 20
               WHEN lower(p.given_name) LIKE ANY(ARRAY[#{lp}]) THEN 12
               ELSE 0 END +
          CASE WHEN lower(p.surname) = ANY(ARRAY[#{ep}]) THEN 20
               WHEN lower(p.surname) LIKE ANY(ARRAY[#{lp}]) THEN 12
               ELSE 0 END +
          similarity(
            lower(COALESCE(p.given_name, '') || ' ' || COALESCE(p.surname, '')),
            lower(?)
          ) * 8 +
          CASE WHEN EXISTS (
            SELECT 1 FROM memberships m JOIN groups g ON g.id = m.group_id
            WHERE m.person_id = p.id AND (
              lower(g.name) LIKE ANY(ARRAY[#{lp}])
              OR lower(COALESCE(m.role, '')) LIKE ANY(ARRAY[#{lp}])
            )
          ) THEN 6 ELSE 0 END +
          CASE WHEN lower(COALESCE(p.current_project, '')) LIKE ANY(ARRAY[#{lp}]) THEN 4 ELSE 0 END +
          CASE WHEN lower(
            COALESCE(p.location_in_building, '') || ' ' ||
            COALESCE(p.building, '') || ' ' ||
            COALESCE(p.city, '')
          ) LIKE ANY(ARRAY[#{lp}]) THEN 4 ELSE 0 END +
          CASE WHEN lower(COALESCE(p.description, '')) LIKE ANY(ARRAY[#{lp}]) THEN 2 ELSE 0 END
        ) AS search_rank
      FROM people p
      WHERE (
        lower(p.given_name) = ANY(ARRAY[#{ep}])
        OR lower(p.surname) = ANY(ARRAY[#{ep}])
        OR lower(p.given_name) LIKE ANY(ARRAY[#{lp}])
        OR lower(p.surname) LIKE ANY(ARRAY[#{lp}])
        OR similarity(lower(COALESCE(p.given_name, '')), lower(?)) > ?
        OR similarity(lower(COALESCE(p.surname, '')), lower(?)) > ?
        OR similarity(
          lower(COALESCE(p.given_name, '') || ' ' || COALESCE(p.surname, '')),
          lower(?)
        ) > ?
        OR EXISTS (
          SELECT 1 FROM memberships m JOIN groups g ON g.id = m.group_id
          WHERE m.person_id = p.id AND (
            lower(g.name) LIKE ANY(ARRAY[#{lp}])
            OR lower(COALESCE(m.role, '')) LIKE ANY(ARRAY[#{lp}])
          )
        )
        OR lower(COALESCE(p.current_project, '')) LIKE ANY(ARRAY[#{lp}])
        OR lower(
          COALESCE(p.location_in_building, '') || ' ' ||
          COALESCE(p.building, '') || ' ' ||
          COALESCE(p.city, '')
        ) LIKE ANY(ARRAY[#{lp}])
        OR lower(COALESCE(p.description, '')) LIKE ANY(ARRAY[#{lp}])
      )
      ORDER BY search_rank DESC, p.surname ASC, p.given_name ASC
      LIMIT #{MAX_RESULTS}
    SQL

    thresh = SIMILARITY_THRESHOLD.to_f
    binds = [
      *terms,
      *like_terms,        # SELECT: given_name exact + like
      *terms,
      *like_terms,        # SELECT: surname exact + like
      @query, # SELECT: full-name similarity
      *like_terms,
      *like_terms, # SELECT EXISTS: group name + role
      *like_terms,                # SELECT: current_project
      *like_terms,                # SELECT: location
      *like_terms,                # SELECT: description
      *terms,
      *terms, # WHERE: given_name =, surname =
      *like_terms,
      *like_terms, # WHERE: given_name LIKE, surname LIKE
      @query,
      thresh,             # WHERE: given_name similarity
      @query,
      thresh,             # WHERE: surname similarity
      @query,
      thresh,             # WHERE: full-name similarity
      *like_terms,
      *like_terms, # WHERE EXISTS: group name + role
      *like_terms,                # WHERE: current_project
      *like_terms,                # WHERE: location
      *like_terms, # WHERE: description
    ]

    Person.find_by_sql([sql, *binds])
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
