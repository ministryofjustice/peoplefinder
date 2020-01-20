class PersonSearch

  attr_reader :query, :results, :matches

  PRE_TAGS = ['<span class="es-highlight">'].freeze
  POST_TAGS = ['</span>'].freeze

  def initialize query, results
    @query = clean_query query
    @query_regexp = /#{@query.downcase}/i
    @email_query = query.strip.downcase
    @results = results
    @max = 100
  end

  # Returns a structure consisting of, Elasticsearch::Model::Response::Records
  # and a boolan denoting whether an "exact" match is included based on the
  # supplied query term and false otherwise.
  #
  # Example:
  #
  # PersonSearch.new('John Smith', SearchResults.new).perform_search
  # #=> [ @set=[#<Elasticsearch::Model::Response::Records], true ]
  #
  def perform_search
    if query.present?
      do_searches unless email_found
    end
    results
  end

  private

  def email_found
    @matches = email_search
    if matches.records.present?
      @results.set = matches.records
      @results.contains_exact_match = true
    end
    @results.present?
  end

  def do_searches
    execute_search
    @results.set = matches.records
    @results.contains_exact_match = exact_match_exists?
  end

  def exact_match_exists?
    @exact_match ||= if single_word_query?
                       matches.records.present?
                     else
                       any_exact_matches?
                     end
  end

  def any_partial_name_matches? results
    results.any? { |m| m.name[@query_regexp] }
  end

  def any_partial_match_for? person, field
    person.send(field) && person.send(field)[@query_regexp]
  end

  def any_partial_match? person
    [:description, :role_and_group, :location, :current_project].any? do |field|
      any_partial_match_for?(person, field)
    end
  end

  def any_exact_matches?
    @results.set.any? do |p|
      (p.name.casecmp(@query) == 0) || any_partial_match?(p)
    end
  end

  def execute_search
    @matches = combined_search
  end

  def combined_search
    @search_definition = {}
    @search_definition[:size] = @max
    @search_definition[:min_score] = 0.02
    @search_definition[:query] = combined_query
    @search_definition[:sort] = sort_query
    @search_definition[:highlight] = highlighter
    search @search_definition
  end

  def clean_query query
    query.
      gsub(/[^[[:alnum:]]’\']/, ' ').
      tr(',', ' ').
      squeeze(' ').
      strip
  end

  def search query
    Person.search_results(query)
  end

  # score descending is the default sorting.
  # for identical scores we sort alphabetically on name
  def sort_query
    {
      _score: { order: 'desc' },
      name: { order: 'asc' }
    }
  end

  # exact match - email is not analyzed (see mappings)
  def email_query
    {
      bool: {
        must: {
          term: {
            email: @email_query
          }
        }
      }
    }
  end

  def email_search
    @search_definition = {}
    @search_definition[:query] = email_query
    @search_definition[:highlight] = highlighter
    search @search_definition
  end

  # exact full name word/token match booster, not including synonyms
  # - promote exact name matches to 1st rank
  def match_standard_name_boost
    {
      match: {
        name: {
          query: @query,
          analyzer: 'standard', # override default name field synonym analyzer
          boost: 6.0 # boost to prioritise exact matches over synonyms
        }
      }
    }
  end

  # exact full name word/token match booster, including synonyms
  # - promote exact name matches with synonyms to 2nd rank
  def match_synonym_name_boost
    {
      match: {
        name: {
          query: @query,
          analyzer: 'name_synonyms_analyzer', # this is the default name field's analyzer
          boost: 4.0 # boost to prioritise synonym matches to 2nd rank
        }
      }
    }
  end

  def multi_match_fuzzy
    {
      multi_match: {
        fields: fields_to_search,
        fuzziness: 2, # maximum allowed Levenshtein Edit Distance/ 'AUTO' is recommended by documention
        prefix_length: 3, # number of initial characters which won't be "fuzzified"
        query: @query,
        analyzer: 'standard'
      }
    }
  end

  # promote fuzzy surname matches above role/group, above full name
  #
  def fields_to_search
    %w(surname^12 role_and_group^6 current_project^4 location^4 name^4)
  end

  def combined_query
    {
      bool: {
        should: [
          match_standard_name_boost,
          match_synonym_name_boost,
          multi_match_fuzzy
        ],
        minimum_should_match: 1,
        boost: 1.0
      }
    }
  end

  def highlighter
    {
      pre_tags: PRE_TAGS,
      post_tags: POST_TAGS,
      fields: fields_to_highlight
    }
  end

  def fields_to_highlight
    {
      name: {},
      role_and_group: {},
      current_project: {},
      email: {}
    }
  end

  def single_word_query?
    !@query[/\s/]
  end

end
