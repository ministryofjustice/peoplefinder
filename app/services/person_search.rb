class PersonSearch
  def fuzzy_search(query, max = 100)
    Person.search(
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
    ).records.limit(max)
  end
end
