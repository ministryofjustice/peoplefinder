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
    ImportOne.new(person).call
  end

  def search(query, limit: 100)
    rows = ActiveRecord::Base.connection.select_rows(
      "SELECT person_id, name, ts_rank(document, plainto_tsquery('english', $1)) from search_index " \
      "WHERE document @@ plainto_tsquery('english', $1) " \
      "ORDER BY ts_rank(document, plainto_tsquery('english', $1)) DESC",
      'text search',
      [[nil, query]]
    )

    people_by_id = Peoplefinder::Person.find(rows.map(&:first)).map {|p| [p.id, p]}
    people_by_id = Hash[people_by_id]

    rows.map { |row| people_by_id[row.first.to_i] }
  end

private
  class ImportOne
    attr_reader :person, :index_language

    def initialize(person, index_language = 'english')
      @person = person
      @index_language = index_language
    end

    def call
      if search_record_exists?
        do_update
      else
        do_insert
      end
    end

    def search_record_exists?
      ActiveRecord::Base.connection.select_one(
        'select person_id from search_index where person_id=$1',
        nil,
        [[nil, person.id]]
      )
    end

    def do_update
      binds = [person.id, person_name] + document_sql.binds
      ActiveRecord::Base.connection.update(
        'UPDATE search_index ' \
        'SET ' \
        'name = $2, ' \
        "document = #{document_sql.sql(2)} " \
        'WHERE person_id = $1',
        'update search index',
        binds.map { |b| [nil, b] }
      )
    end

    def do_insert
      ActiveRecord::Base.connection.insert(
        'INSERT INTO search_index (person_id, name, document) ' \
        'VALUES ' \
        "($1, $2, #{document_sql.sql(2)})",
        nil, nil, nil, nil,
        ([person.id, person_name] + document_sql.binds).map { |b| [nil, b] }
      )
    end

    def person_name
      "#{person.given_name} #{person.surname}"
    end

    def document_sql
      indexable_data = [
        [person_name, 'A'],
        [person.location || ''],
        [person.description || ''],
        [person.role_and_group || ''],
        [person.community_name || ''],
        [person.tags || '']
      ]
      indexable_data.map do |data, weight|
        BoundSql.new('setweight(to_tsvector($1, $2), $3)', [index_language, data, weight || 'D'])
      end.inject { |memo, elem| memo.join(elem) }
    end

    class BoundSql
      attr_reader :binds

      def initialize(sql, binds)
        @sql = sql
        @binds = binds
      end

      def sql(bind_number_offset = 0)
        @sql.gsub(/\$([0-9]+)/) do |_|
          '$' + ($1.to_i + bind_number_offset).to_s
        end
      end

      def join(other, join_sql = '||')
        BoundSql.new(
          self.sql + join_sql + other.sql(self.binds.size),
          self.binds + other.binds
        )
      end
    end
  end


end
