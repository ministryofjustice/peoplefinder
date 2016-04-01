class PersonSearch

  def initialize query
    @query = clean_query query
    @email_query = query.strip.downcase
    @max = 100
  end

  def perform_search
    return [] if @query.blank?

    email_match = email_search
    if email_match
      [email_match]
    else
      exact_matches, name_matches, query_matches, fuzzy_matches = perform_searches
      exact_matches.
        push(*name_matches).
        push(*query_matches).
        push(*fuzzy_matches).
        uniq[0..@max - 1]
    end
  end

  private

  def email_search
    Person.find_by_email(@email_query)
  end

  def perform_searches
    name_matches = search "name:#{@query}"
    query_matches = search @query
    fuzzy_matches = fuzziness_search
    exact_matches = name_matches.select { |p| p.name == @query }

    [exact_matches, name_matches, query_matches, fuzzy_matches]
  end

  def fuzziness_search
    search(
      size: @max,
      query: {
        multi_match: {
          fields: fields_to_search,
          query: @query, fuzziness: 'AUTO'
        }
      }
    )
  end

  def fields_to_search
    [
      :name, :tags, :description, :location_in_building, :building,
      :city, :role_and_group, :community_name, :current_project
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
    Person.search_results(query, limit: @max)
  end
end
