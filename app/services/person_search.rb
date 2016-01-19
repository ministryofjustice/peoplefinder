class PersonSearch

  def initialize query
    @query = clean_query query
    @max = 100
  end

  def perform_search
    return [] if @query.blank?

    name_matches, query_matches, fuzzy_matches = perform_searches
    exact_matches = name_matches.select { |p| p.name == @query }
    (exact_matches + name_matches + query_matches + fuzzy_matches).uniq[0..@max - 1]
  end

  private

  def perform_searches
    name_matches = search "name:#{@query}"
    query_matches = search @query
    fuzzy_matches = fuzzy_search

    [name_matches, query_matches, fuzzy_matches]
  end

  def fuzzy_search
    search(
      size: @max,
      query: {
        fuzzy_like_this: {
          fields: [
            :name, :tags, :description, :location_in_building, :building,
            :city, :role_and_group, :community_name
          ],
          like_text: @query, prefix_length: 3, ignore_tf: true
        }
      }
    )
  end

  def clean_query query
    query.
      tr(',', ' ').
      squeeze(' ').
      strip
  end

  def search query
    Person.search_results(query, limit: @max)
  end
end
