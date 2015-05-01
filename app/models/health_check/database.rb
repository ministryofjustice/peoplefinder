module HealthCheck
  class Database < Component
    def accessible?
      begin
        tuple = execute_simple_select_on_database
        result = tuple.to_a == [{ 'result' => '1' }]
      rescue => e
        log_unknown_error(e)
        result = false
      end
      result
    end

    def available?
      begin
        result = ActiveRecord::Base.connected?
        log_error unless result == true
      rescue => e
        log_unknown_error(e)
        result = false
      end
      result
    end

  private

    def execute_simple_select_on_database
      ActiveRecord::Base.connection.execute('select 1 as result')
    end

    def log_error
      @errors = [
        'Database Error: could not connect to %s on %s using %s' % [
          config.database, config.host, config.adapter
        ]
      ]
    end

    def config
      OpenStruct.new(Rails.configuration.database_configuration[Rails.env])
    end
  end
end
