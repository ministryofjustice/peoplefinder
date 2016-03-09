require 'uri'

module HealthCheck
  class DatabaseConfiguration
    SAFE = %w( adapter database host port ).freeze

    def initialize(hash)
      @hash = if hash.key?('url')
                parse_out_uri(hash)
              else
                hash
              end
    end

    def to_s
      @hash.
        sort.
        select { |k, v| SAFE.include?(k.to_s) && v }.
        map { |k, v| "#{k}=#{v}" }.
        join(' ')
    end

    private

    def parse_out_uri(hash)
      uri = URI.parse(hash['url'])
      hash.merge(
        'database' => uri.path[1..-1],
        'host' => uri.hostname,
        'port' => uri.port
      )
    end
  end
end
