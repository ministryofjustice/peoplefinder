require 'geckoboard'

module GeckoboardPublisher
  class Report

    attr_reader :client

    def initialize
      @client = Geckoboard.client(ENV['GECKOBOARD_API_KEY'])
      test_client
    end

    def create_dataset!
      client.datasets.find_or_create(dataset_name, fieldset, unique_by)
    end

    def publish!
      raise "Implement #{__method__} in subclass"
    end

    private

    def dataset_name
      raise "Implement #{__method__} in subclass"
    end

    def fieldset
      raise "Implement #{__method__} in subclass"
    end

    def unique_by
      raise "Implement #{__method__} in subclass"
    end

    def test_client
      begin
        @client.ping
      rescue Geckoboard::UnauthorizedError => err
        Rails.logger.warn "#{err} Geckoboard API key is not authorized for #{self.class}"
        raise
      end
    end
  end
end