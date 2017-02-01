module SpecSupport
  module ElasticSearchHelper

    def hit_count
      Person.search('*').results.total
    end

    def all_documents
      Person.search('*').records.map_with_hit do |rec, hit|
        { name: rec.name, score: hit._score }
      end
    end

    def print_all_documents
      p = IO.popen("curl -i -XGET 'localhost:9200/#{Person.index_name}/person/_search?pretty'")
      puts p.readlines
      p.close
    end

    def index_health
      Person.__elasticsearch__.client.cluster.health
    end
  end
end
