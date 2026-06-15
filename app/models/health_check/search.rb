module HealthCheck
  class Search < Component
    def available?
      Person.connection.extension_enabled?("pg_trgm").tap do |ok|
        log_error("pg_trgm extension is not enabled — search will not work") unless ok
      end
    rescue StandardError => e
      log_unknown_error e
      false
    end

    def accessible?
      true
    end
  end
end
