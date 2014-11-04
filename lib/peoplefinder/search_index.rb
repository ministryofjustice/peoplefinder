require 'peoplefinder'

class Peoplefinder::SearchIndex
  def import(people)
    people.each do |person|
      person.__elasticsearch__.index_document
    end
  end

  def flush
    Peoplefinder::Person.__elasticsearch__.client.indices.refresh
  end

  def search(query, limit: 100)
    Peoplefinder::Person.search(
      size: 100,
      query: {
        fuzzy_like_this: {
          fields: [
            :name, :tags, :description, :location,
            :role_and_group, :community_name],
          like_text: query, prefix_length: 3, ignore_tf: true
        }
      }
    ).records.limit(limit)
  end
end
