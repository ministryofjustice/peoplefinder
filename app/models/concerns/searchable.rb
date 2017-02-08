
module Concerns::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # Force a full re-index after update, the ActiveModel::Dirty tracking
    # doesn't detect changes to community_name.
    # Don't know if we still need this, as we have removed community feature.
    after_commit -> { __elasticsearch__.index_document }, on: :update

    index_name [Rails.env, model_name.collection.gsub(/\//, '-')].join('_')

    def self.delete_indexes
      __elasticsearch__.delete_index! index: index_name
    end

    def self.search_results(query)
      search(query)
    end

    settings analysis: {
      filter: {
        name_synonyms_expand: {
          type: 'synonym',
          synonyms: File.readlines(Rails.root.join('config', 'initializers', 'name_synonyms.csv')).map(&:chomp)
        }
      },
      analyzer: {
        name_synonyms_expand: {
          tokenizer: 'whitespace',
          filter: %w(
            lowercase
            name_synonyms_expand)
        }
      }
    } do
      mapping do
        indexes :name, search_analyzer: 'name_synonyms_expand', type: 'string'
      end
    end
  end
end
