module HealthCheck
  class OpenSearch < Component
    def available?
      client.ping.tap { |ok| log_error("Could not connect to #{hosts}") unless ok }
    rescue StandardError => e
      log_unknown_error e
      false
    end

    def accessible?
      return true if cluster_status?("green")

      log_error("Cluster status is #{client.cluster.health['status']}")
      false
    end

  private

    def cluster_status?(expected_status)
      client.cluster.health["status"] == expected_status
    end

    def log_error(message)
      @errors = ["OpenSearch Error: #{message}"]
    end

    def hosts
      client.transport.transport.hosts.map { |h|
        "port #{h[:port]} on #{h[:host]} via #{h[:protocol]}"
      }.join("; ")
    end

    def client
      ::OpenSearch::Model.client
    end
  end
end
