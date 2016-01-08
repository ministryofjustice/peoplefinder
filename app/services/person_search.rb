class PersonSearch
  def fuzzy_search(query, max = 100)
    return [] if query.blank?
    @max = max
    name_matches = search "name:#{query}"
    exact_matches = search query
    fuzzy_matches = search(
      size: max,
      query: {
        fuzzy_like_this: {
          fields: [
            :name, :tags, :description, :location_in_building, :building,
            :city, :role_and_group, :community_name
          ],
          like_text: query, prefix_length: 3, ignore_tf: true
        }
      }
    )

    (name_matches + exact_matches + fuzzy_matches).uniq[0..max-1]
  end

  private

  def search query
    Person.search(query).records.limit(@max)
  end
end
