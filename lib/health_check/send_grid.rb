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
      response = Net::SMTP.start(@config.address, @config.port) do |smtp|
        smtp.helo(@config.sending_host)
      end

      !!response

    rescue *ERRS_TO_CATCH => e
      log_error('Access', e)
      false
    rescue => e
      log_unknown_error(e)
      false
    end

    def accessible?
      response = Net::SMTP.start(@config.address, @config.port) do |smtp|
        smtp.authenticate(
          @config.user_name,
          @config.password,
          @config.authentication
        )
      end

      !!response

    rescue *ERRS_TO_CATCH => e
      log_error('Authentication', e)
      false
    rescue => e
      log_unknown_error(e)
      false
    end

    private

    def log_error(type, e)
      @errors << "SendGrid #{type} Error: #{e.message}"
    end
  end
end
