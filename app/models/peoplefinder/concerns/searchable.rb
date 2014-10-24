require 'peoplefinder'

module Peoplefinder::Concerns::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name [Rails.env, model_name.collection.gsub(/\//, '-')].join('_')

    def self.delete_indexes
      __elasticsearch__.delete_index! index: Peoplefinder::Person.index_name
    end

    def self.fuzzy_search(query)
      search(
        size: 100,
        query: {
          fuzzy_like_this: {
            fields: [:name, :tags, :description, :location, :role_and_group],
            like_text: query, prefix_length: 3, ignore_tf: true
          }
        }
      )
    end

    def as_indexed_json(_options = {})
      as_json(
        only: [:tags, :description, :location],
        methods: [:name, :role_and_group]
      )
    end
  end
end
