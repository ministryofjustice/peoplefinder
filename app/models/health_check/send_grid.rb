module HealthCheck
  class SendGrid < Component
    ERRS_TO_CATCH =
    [
      SocketError,
      Net::SMTPAuthenticationError,
      Net::SMTPServerBusy,
      Net::SMTPSyntaxError,
      Net::SMTPFatalError,
      Net::SMTPUnknownError,
      Net::OpenTimeout,
      Net::ReadTimeout,
      IOError
    ]

    def initialize
      @config = OpenStruct.new(ActionMailer::Base.smtp_settings)
      super
    end

    def available?
      with_error_detection('Access') do
        Net::SMTP.start(@config.address, @config.port) do |smtp|
          smtp.helo(@config.sending_host)
        end
      end
    end

    def accessible?
      with_error_detection('Authentication') do
        Net::SMTP.start(@config.address, @config.port) do |smtp|
          smtp.authenticate(
            @config.user_name,
            @config.password,
            @config.authentication
          )
        end
      end
    end

    private

    def with_error_detection(desc)
      yield
      true
    rescue *ERRS_TO_CATCH => e
      log_error desc, e
      false
    rescue => e
      log_unknown_error e
      false
    end

    def log_error(type, e)
      @errors << "SendGrid #{type} Error: #{e.message}"
    end
  end
end
