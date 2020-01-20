module SpecSupport
  module ElasticSearchHelper

    def total_document_count
      Person.search('*').results.total
    end

    def all_es_rails_documents(limit: 100)
      response = Person.search(match_all(size: limit))
      response.records.map_with_hit do |rec, hit|
        { name: rec.name, hit: hit }
      end
    end

    def all_documents(limit: 100)
      IO.popen("curl -i -XGET '#{Rails.configuration.elastic_search_url}:9200/#{Person.index_name}/person/_search?size=#{limit}&pretty'", &:readlines)
    end

    def all_mappings
      IO.popen("curl '#{Rails.configuration.elastic_search_url}:9200/test_people/_mappings?pretty'", &:readlines)
    end

    def index_health
      Person.__elasticsearch__.client.cluster.health
    end

    # add some helpers to elastic search itself
    class Elasticsearch::Model::Response::Records
      def names_with_score
        map_with_hit { |rec, hit| [rec.name, hit._score] }
      end

      def names_with_hit
        map_with_hit { |rec, hit| [rec.name, hit] }
      end
    end

    private

    def match_all(size: 100)
      {
        size: size,
        query: {
          match_all: {}
        }
      }
    end
  end
end
