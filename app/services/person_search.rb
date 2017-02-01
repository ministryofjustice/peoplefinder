class PersonSearch

  attr_reader :query, :results, :phrase_name_matches, :phrase_matches, :fuzzy_matches

  def initialize query, results
    @query = clean_query query
    @query_regexp = /#{@query.downcase}/i
    @email_query = query.strip.downcase
    @results = results
    @max = 100
  end

  # Returns a two element array, first element is the list of results, second
  # element is a boolean which is true when the results contain an exact match
  # for supplied query term and false otherwise.
  #
  # Example:
  #
  # PersonSearch.new('John Smith', SearchResults.new).perform_search
  # #=> [ [#<Person given_name: "John", surname: "Smith"], true ]
  #
  # PersonSearch.new('John Zoolander', SearchResults.new).perform_search
  # #=> [ [#<Person given_name: "John", surname: "Smith"], false ]
  def perform_search
    if @query.present?
      do_searches unless email_found(@email_query)
    end
    @results
  end

  def email_found(email)
    person = Person.find_by_email(email)
    if person
      @results.set = [person]
      @results.contains_exact_match = true
    end
    @results.present?
  end

  def do_searches
    perform_searches

    results = [].
              push(*phrase_name_matches).
              push(*phrase_matches).
              push(*fuzzy_matches).
              uniq[0..@max - 1]

    @results.set = results
    @results.contains_exact_match = exact_match_exists?
  end

  def exact_match_exists?
    @exact_match ||= if single_word_query?
                       phrase_name_matches.present? ||
                         phrase_matches.present? ||
                         any_partial_name_matches?(fuzzy_matches) ||
                         any_exact_matches?
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
    [:description, :role_and_group, :location_in_building, :building, :city, :current_project].any? do |field|
      any_partial_match_for?(person, field)
    end
  end

  def any_exact_matches?
    @results.set.any? do |p|
      (p.name.casecmp(@query) == 0) || any_partial_match?(p)
    end
  end

  def perform_searches
    @phrase_name_matches = phrase_name_search
    @phrase_matches = phrase_search
    @fuzzy_matches = fuzzy_search
  end

  # search name field for exact "phrase" with synonym and exact match boost
  # NOTE: includes synonyms equivalence
  #
  def phrase_name_search
    @search_definitiion = {}
    @search_definitiion[:query] = phrase_name_query
    search @search_definitiion
  end

  # search all indexed fields for any phrase matches
  # NOTE: does NOT include synonym equivalence
  #
  def phrase_search
    search %("#{@query}")
  end

  def fuzzy_search
    results = search(
      size: @max,
      query: fuzzy_query
    )

    sort_by_edit_distance(results)
  end

  def sort_by_edit_distance results
    if any_close_by_edit_distance? results
      results.sort_by { |x| Text::Levenshtein.distance(x.name, @query) }
    else
      results
    end
  end

  def any_close_by_edit_distance? results
    edit_distances = results.map { |x| Text::Levenshtein.distance(x.name, @query) }
    edit_distances.any? { |e| e > 0 && e < 4 }
  end

  def fields_to_search
    %w(name surname^4 description location_in_building building city role_and_group current_project)
  end

  def clean_query query
    query.
      gsub(/[^[[:alnum:]]’\']/, ' ').
      tr(',', ' ').
      squeeze(' ').
      strip
  end

  def search query
    Person.search_results(query, limit: @max).to_a
  end

  private

  def phrase_name_query
    {
      bool: {
        must: match_name_synonym_phrase,
        should: match_standard_name_boost
      }
    }
  end

  def match_name_synonym_phrase
    {
      match_phrase: {
        name: {
          query: @query,
          analyzer: 'name_synonyms_expand' # default analyzer for name field but clearer o be explicit
        }
      }
    }
  end

  def match_standard_name_boost
    {
      match: {
        name: {
          query: @query,
          analyzer: 'standard', # override default synonym analyzer
          boost: 10.0 # boost to prioritise exact matches over synonyms
        }
      }
    }
  end

  def fuzzy_query
    {
      multi_match: {
        fields: fields_to_search,
        fuzziness: 1, # maximum allowed Levenshtein Edit Distance/ 'AUTO' is recommended by documention
        prefix_length: 1, # number of initial characters which won't be "fuzzified"
        query: @query
      }
    }
  end

  def single_word_query?
    !@query[/\s/]
  end

end
