require 'peoplefinder'

module Peoplefinder::Concerns::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # Force a full re-index after update, the ActiveModel::Dirty tracking
    # doesn't detect changes to community_name
    after_commit -> { __elasticsearch__.index_document }, on: :update

    index_name [Rails.env, model_name.collection.gsub(/\//, '-')].join('_')

    settings analysis: {
      analyzer: {
        name: {
          tokenizer: 'whitespace',
          filter: ['name_synonym']
        }
      },
      filter: {
        name_synonym: {
          type: 'synonym',
          ignore_case: true,
          expand: true,
          synonyms_path: Peoplefinder::Engine.root.join('config/names.txt').to_s
        }
      }
    } do
      mappings dynamic: 'true' do
        indexes :name, analyzer: 'name'
      end
    end

    def self.delete_indexes
      __elasticsearch__.delete_index! index: Peoplefinder::Person.index_name
    end

    def self.fuzzy_search(query)
      search(
        size: 100,
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
    end

    def as_indexed_json(_options = {})
      as_json(
        only: [:tags, :description, :location_in_building, :building, :city],
        methods: [:name, :role_and_group, :community_name]
      )
    end
  end
end
