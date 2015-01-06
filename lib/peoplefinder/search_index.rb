require 'peoplefinder'

class Peoplefinder::SearchIndex
  def import(people)
    people.each do |person|
      index(person)
    end
  end

  def delete(person)
    ActiveRecord::Base.connection.delete(
      'DELETE from search_index where person_id=$1',
      'delete person',
      [[nil, person.id]]
    )
  end

  def index(person)
    Peoplefinder::PersonIndexer.new(person).call
  end

  def search(query, limit: 100)
    rows = ActiveRecord::Base.connection.select_rows(%q{
      SELECT person_id
      FROM search_index
      WHERE document @@ plainto_tsquery('english', $1)
      ORDER BY ts_rank(document, plainto_tsquery('english', $1)) DESC
      LIMIT $2
      },
      'text search',
      [[nil, query], [nil, limit]]
    )

    people_ids = rows.map { |row| row.first.to_i }
    load_people_in_order(people_ids)
  end

private

  def load_people_in_order(people_ids)
    people = Peoplefinder::Person.find(people_ids)
    people_by_id = Hash[people.map { |p| [p.id, p] }]
    people_ids.map { |id| people_by_id[id] }
  end
end
