module SpecSupport
  module ElasticSearchHelper

    def total_document_count
      Person.search('*').results.total
    end

    def all_documents(limit: 100)
      response = Person.search(match_all(limit: limit))
      response.records.map_with_hit do |rec, hit|
        { name: rec.name, hit: hit }
      end
    end

    def all_curl_documents(limit: 100)
      response = IO.popen("curl -i -XGET 'localhost:9200/#{Person.index_name}/person/_search?size=#{limit}&pretty'")
      lines = response.readlines
      response.close
      lines
    end

    def all_curl_mappings
    response = IO.popen("curl 'localhost:9200/test_people/_mappings?pretty'")
    lines = response.readlines
    response.close
    lines
    end

    def index_health
      Person.__elasticsearch__.client.cluster.health
    end

    class Elasticsearch::Model::Response::Records
      def name_with_score
        self.map_with_hit { |rec, hit| [ rec.name, hit._score] }
      end
    end

    private

    def match_all(limit: 100)
      {
        size: limit,
        query: {
          match_all: {}
        }
      }
    end

  end
end
