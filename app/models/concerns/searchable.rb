module Concerns::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name [Rails.env, model_name.collection.tr('/', '-')].join('_')

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
          synonyms: File.readlines(Rails.root.join('config/initializers/name_synonyms.csv')).map(&:chomp)
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
        indexes :name, search_analyzer: 'name_synonyms_analyzer', type: :text, fielddata: true, analyzer: :standard
        indexes :email, type: :keyword
      end
    end

  end
end
