class PersonSearch

  attr_reader :exact_name_matches, :name_matches, :exact_matches, :query_matches, :fuzzy_matches

  def initialize query
    @query = clean_query query
    @email_query = query.strip.downcase
    @max = 100
  end

  def perform_search
    return [] if @query.blank?

    email_match = email_search
    return [email_match] if email_match

    @exact_name_matches, @exact_matches, @query_matches, @fuzzy_matches = perform_searches

    [].push(*@exact_name_matches).
      push(*@exact_matches).
      push(*@query_matches).
      push(*@fuzzy_matches).
      uniq[0..@max - 1]
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
    search @query
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
