module HealthCheck
  class Database < Component
    def accessible?
      true
    end

    def available?
      begin
        tuple = execute_simple_select_on_database
        result = tuple.to_a == [{ "result" => 1 }]
      rescue StandardError => e
        log_unknown_error(e)
        result = false
      end
      result
    end

  private

    def execute_simple_select_on_database
      ActiveRecord::Base.connection.execute("select 1 as result")
    end
  end
end
