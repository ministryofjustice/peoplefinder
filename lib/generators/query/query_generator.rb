class QueryGenerator < Rails::Generators::NamedBase

  def create_query_object_file
    create_file "app/models/query/#{file_name}_query.rb", <<-FILE
module Query

  class #{class_name}Query

    class << self
      delegate :call, to: :new
    end

    def initialize(relation = Person.all)
      @relation = relation
    end

    def call
      @relation.where(login_count: 0)
    end
  end
end
FILE
  end

  def create_query_object_spec_file
    create_file "spec/models/query/#{file_name}_query_spec.rb", <<-FILE
require 'rails_helper'

module Query
  describe #{class_name}Query do

    describe '#call' do
      it 'generates the expected sql' do
        expect(#{class_name}Query.new.call.to_sql).to match_sql expected_sql
      end

      it 'returns an arel relation' do
        expect(#{class_name}Query.new.call).to be_an_instance_of(Person::ActiveRecord_Relation)
      end

      it 'returns expected records' do
        # add test here
      end

      def expected_sql
        '
          #add expected SQL here
        '
      end
    end
  end
end
FILE
  end
end
