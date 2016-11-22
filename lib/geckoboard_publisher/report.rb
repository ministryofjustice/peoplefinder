# wrapper for geckoboard-ruby gem
# see https://developer.geckoboard.com/api-reference/ruby/

require 'geckoboard'

module GeckoboardPublisher
  class Report

    # geckboard datasets can only accept 500 sets per POST or PUT
    # and only 5000 sets maximum
    ITEMS_CHUNK_SIZE = 500.freeze

    attr_reader :client, :dataset

    def initialize
      @published = false
      @force = false
      @client = Geckoboard.client(ENV['GECKOBOARD_API_KEY'])
      test_client
    end

    def publish! force = false
      @force = force
      create_dataset!
      replace_dataset!.tap do |result|
        cron_logger.info "publishing #{self.class.name} has #{result.to_string_boolean}"
      end
    rescue Geckoboard::ConflictError => e
      cron_logger.error "#{self.class.name} call of #{__method__} raised #{e}"
      force? ? overwrite! : raise
    end

    def unpublish!
      client.datasets.delete(id)
      @published = false
    rescue Geckoboard::UnexpectedStatusError => e
      cron_logger.error "#{self.class.name} call of #{__method__} raised #{e}"
      false
    end

    # geckoboard-ruby gem's dataset.find_or_create id attribute
    # e.g. peoplefinder-staging.total_profiles_report
    def id
      Rails.application.class.parent_name.underscore +
        '-' +
        (ENV['ENV'] || Rails.env).downcase +
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

    def force?
      @force
    end

    def published?
      @published
    end

    private

    def create_dataset!
      @dataset = client.datasets.find_or_create(id, fields: fields, unique_by: unique_by)
    end

    def replace_dataset!
      items.each_slice(ITEMS_CHUNK_SIZE) do |chunk|
        @published = dataset.put(chunk)
        break unless published?
      end
      published?
    end

    def overwrite!
      unpublish!
      publish! false
    end

    def test_client
      @client.ping
    rescue Geckoboard::UnauthorizedError => err
      Rails.logger.warn "#{err} Geckoboard API key is not authorized for #{self.class}"
      raise
    end

    def cron_logger
      @logger ||= Logger.new(STDOUT).tap do |log|
        log.progname = 'Worker cron job'
        log.level = Rails.env.test? ? Logger::UNKNOWN : Logger::DEBUG
      end
    end
  end
end

class Object
  def to_string_boolean
    return 'failed' if [FalseClass, NilClass].include?(self.class)
    return 'succeeded' if self.class == TrueClass
    self
  end
end
