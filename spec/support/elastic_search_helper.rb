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

    def print_all_documents(limit: 100)
      p = IO.popen("curl -i -XGET 'localhost:9200/#{Person.index_name}/person/_search?size=#{limit}&pretty'")
      puts p.readlines
      p.close
    end

    def index_health
      Person.__elasticsearch__.client.cluster.health
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
