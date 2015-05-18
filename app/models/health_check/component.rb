module HealthCheck
  class Component
    #
    # Define interface to check if component passes the healthcheck
    #
    def initialize
      @errors = []
    end

    attr_reader :errors

    def log_unknown_error(e)
      #
      # Logs errors that are not component specific
      # StandardError -> Null
      #
      @errors << "Error: #{e.message}\nDetails:#{e.backtrace}"
    end
  end
end
