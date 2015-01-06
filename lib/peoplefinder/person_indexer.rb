require 'peoplefinder'

class Peoplefinder::PersonIndexer
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

private

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
    concatenate(
      bound_sql_for(person_name, 'A'),
      bound_sql_for(person.location),
      bound_sql_for(person.description),
      bound_sql_for(person.role_and_group),
      bound_sql_for(person.community_name),
      bound_sql_for(person.tags)
    )
  end

  def bound_sql_for(data, weight = 'D')
    BoundSql.new(
      'setweight(to_tsvector($1, $2), $3)',
      [index_language, data || '', weight || 'D']
    )
  end

  def concatenate(*bound_sql_list)
    bound_sql_list.inject { |memo, elem| memo.join(elem) }
  end

  class BoundSql
    attr_reader :binds

    def initialize(sql, binds)
      @sql = sql
      @binds = binds
    end

    def sql(bind_number_offset = 0)
      @sql.gsub(/\$([0-9]+)/) do |_|
        '$' + (Regexp.last_match[1].to_i + bind_number_offset).to_s
      end
    end

    def join(other, join_operator = '||')
      BoundSql.new(
        self.sql + join_operator + other.sql(self.binds.size),
        self.binds + other.binds
      )
    end
  end
end
