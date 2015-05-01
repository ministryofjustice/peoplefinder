module HealthCheck
  class PqaApi < Component

    TIMESTAMP_FILE = "#{Rails.root}/tmp/pqa_api_healthcheck_timestamp"

    ERRS_TO_CATCH =
    [
      Net::ReadTimeout,
      Errno::ECONNREFUSED,
      SocketError,
      HTTPClient::FailureResponse
     ]

    def self.time_to_run?
      interval = get_minimum_interval_in_seconds
      time_last_run = get_time_last_run
      Time.now.to_i > interval + time_last_run
    end


    def initialize
      @api = PQA::ApiClient.from_settings
      super
      record_time_ran
    end

    def available?
      res = perform_get(Settings.pq_rest_api.host)
      !!(res.code =~ /^2/)

    rescue *ERRS_TO_CATCH => e
      log_error('Access', e)
      false
    rescue => e
      log_unknown_error(e)
      false
    end

    def accessible?
      res = @api.question('1')
      !!(res.code =~ /^2/)

    rescue *ERRS_TO_CATCH => e
      log_error('Authentication', e)
      false
    rescue => e
      log_unknown_error(e)
      false
    end

    private

    def self.get_minimum_interval_in_seconds
      Settings.healthcheck_pqa_api_interval * 60
    end

    def self.get_time_last_run
      if File.exist?(TIMESTAMP_FILE)
        File.open(TIMESTAMP_FILE, 'r') do |fp|
          interval = fp.gets.chomp.to_i
        end
      else
        0
      end
    end


    def record_time_ran
      tmpdir = "#{Rails.root}/tmp"
      Dir.mkdir(tmpdir) unless Dir.exist?(tmpdir)
      File.open(TIMESTAMP_FILE, 'w') do |fp|
        fp.puts Time.now.to_i
      end
    end

    def log_error(type, e)
      @errors << "PQA API #{type} Error: #{e.message}"
    end

    def perform_get(uri_s)
      uri = URI.parse(uri_s)

      Net::HTTP.start(uri.host, uri.port) do |http|
        req = Net::HTTP::Get.new(uri)
        http.request(req)
      end
    end
  end
end