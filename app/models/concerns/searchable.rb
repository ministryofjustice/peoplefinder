module Concerns::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    document_type "doc"
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
        name_synonyms_analyzer: {
          tokenizer: 'whitespace',
          filter: %w(
            lowercase
            name_synonyms_expand)
        }
      }
    } do
      mapping do
        # indexes :name, search_analyzer: 'name_synonyms_analyzer', analyzer: 'standard', type: 'keyword'
        indexes :name, search_analyzer: 'name_synonyms_analyzer', type: :text, fielddata: true, analyzer: :english
        indexes :email #, index: :not_analyzed
      end
    end
  end
end
