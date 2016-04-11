class PersonSearch

  attr_reader :query, :results, :exact_name_matches, :name_matches, :exact_matches, :query_matches, :fuzzy_matches

  def initialize query
    @query = clean_query query
    @query_regexp = /#{@query.downcase}/i
    @email_query = query.strip.downcase
    @max = 100
  end

  # Returns a two element array, first element is the list of results, second
  # element is a boolean which is true when the results contain an exact match
  # for supplied query term and false otherwise.
  #
  # Example:
  #
  # PersonSearch.new('John Smith').perform_search
  # #=> [ [#<Person given_name: "John", surname: "Smith"], true ]
  #
  # PersonSearch.new('John Zoolander').perform_search
  # #=> [ [#<Person given_name: "John", surname: "Smith"], false ]
  def perform_search
    return [[], @exact_match = false] if @query.blank?

    email_match = email_search
    return [[email_match], @exact_match = true] if email_match

    @exact_name_matches, @exact_matches, @query_matches, @fuzzy_matches = perform_searches

    @results = [].
              push(*@exact_name_matches).
              push(*@exact_matches).
              push(*@query_matches).
              push(*@fuzzy_matches).
              uniq[0..@max - 1]

    @results = sort_by_edit_distance @results
    [@results, exact_match_exists?]
  end

  def exact_match_exists?
    @exact_match ||= if single_word_query?
                       @exact_name_matches.present? ||
                         @exact_matches.present? ||
                         any_partial_name_matches?(@query_matches) ||
                         any_partial_name_matches?(@fuzzy_matches) ||
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

  def any_exact_matches?
    downcase_query = @query.downcase
    @results.any? do |p|
      (p.name.downcase == downcase_query) ||
      any_partial_match_for?(p, :description) ||
      any_partial_match_for?(p, :role_and_group) ||
      any_partial_match_for?(p, :location_in_building) ||
      any_partial_match_for?(p, :building) ||
      any_partial_match_for?(p, :city) ||
      any_partial_match_for?(p, :current_project)
    end
  end

  def email_search
    Person.find_by_email(@email_query)
  end

  def perform_searches
    exact_matches = exact_search
    query_matches = query_search
    fuzzy_matches = fuzziness_search
    exact_name_matches = exact_matches.select { |p| p.name == @query }
    if single_word_query?
      exact_name_matches += query_matches.select { |p| p.name[/^#{@query} /i] }.sort_by(&:name)
    end

    [exact_name_matches, exact_matches, query_matches, fuzzy_matches]
  end

  def exact_search
    search %("#{@query}")
  end

  def query_search
    search(@query)
  end

  def single_word_query?
    !@query[/\s/]
  end

  def fuzziness_search
    search(
      size: @max,
      query: {
        multi_match: {
          fields: fields_to_search,
          fuzziness: 1, # maximum allowed Levenshtein Edit Distance
          prefix_length: 1, # number of initial characters which won't be "fuzzified"
          query: @query
        }
      }
    )
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
    [
      :name, :description, :location_in_building, :building,
      :city, :role_and_group, :current_project
    ]
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

end
