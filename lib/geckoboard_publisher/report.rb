# wrapper for geckoboard-ruby gem
# see https://developer.geckoboard.com/api-reference/ruby/

require 'geckoboard'

module GeckoboardPublisher
  class Report

    attr_reader :client
    attr_reader :dataset

    def initialize
      @client = Geckoboard.client(ENV['GECKOBOARD_API_KEY'])
      test_client
    end

    def publish!
      create_dataset!
      replace_dataset!
    end

    # geckoboard-ruby gem's dataset.find_or_create id attribute
    # e.g. peoplefinder-staging.total_profiles_report
    def id
      Rails.application.class.parent_name.underscore +
        '-' +
        (Rails.host.env.downcase rescue Rails.env) +
        '.' +
        self.class.name.demodulize.underscore
    end

    # geckoboard-ruby gem's dataset.find_or_create fields hash
    # e.g.
    # [
    #   Geckoboard::MoneyField.new(:amount, name: 'Amount', currency_code: 'USD'),
    #   Geckoboard::DateTimeField.new(:timestamp, name: 'Time')
    # ]
    def fields
      raise "Implement #{__method__} in subclass"
    end

    # geckoboard-ruby gem's dataset.find_or_create unique_by hash
    # e.g.
    # [:mydatefield]
    def unique_by
    end

    def items
      raise "Implement #{__method__} in subclass"
    end

    private

    def create_dataset!
      @dataset = client.datasets.find_or_create(id, fields: fields, unique_by: unique_by)
    rescue Geckoboard::ConflictError
      client.datasets.delete(id)
      create_dataset!
    end

    def replace_dataset!
      dataset.put items
    end

    def test_client
      @client.ping
    rescue Geckoboard::UnauthorizedError => err
      Rails.logger.warn "#{err} Geckoboard API key is not authorized for #{self.class}"
      raise
    end
  end
end
