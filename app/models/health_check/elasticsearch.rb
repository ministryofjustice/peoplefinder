module HealthCheck
  class Elasticsearch < Component
    def accessible?
      client.ping.tap { |ok| log_error unless ok }
    rescue => err
      log_unknown_error err
      false
    end

    alias_method :available?, :accessible?

  private

    def log_error
      @errors = ["Elasticsearch Error: could not connect to #{hosts}"]
    end

    def hosts
      client.transport.hosts.map { |h|
        "port #{h[:port]} on #{h[:host]} via #{h[:protocol]}"
      }.join('; ')
    end

    def client
      ::Elasticsearch::Model.client
    end
  end
end
