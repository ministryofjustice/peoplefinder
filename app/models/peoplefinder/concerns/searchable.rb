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

    def self.delete_indexes
      __elasticsearch__.delete_index! index: Peoplefinder::Person.index_name
    end

    def as_indexed_json(_options = {})
      as_json(
        only: [:tags, :description, :location],
        methods: [:name, :role_and_group, :community_name]
      )
    end
  end
end
