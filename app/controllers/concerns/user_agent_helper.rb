module UserAgentHelper
  extend ActiveSupport::Concern

  Browser = Struct.new(:browser, :version)

  UNSUPPORTED_BROWSER = [
    Browser.new(UserAgent::Browsers::InternetExplorer.new.browser, UserAgent::Version.new('7.0'))
  ].freeze

  included do
    helper_method :unsupported_browser?, :user_agent

    def user_agent
      @ua ||= UserAgent.parse(request.user_agent)
    end

    def supported_browser?
      UNSUPPORTED_BROWSER.none? do |unsupported_user_agent|
        user_agent <= unsupported_user_agent
      end
    end

    def unsupported_browser?
      !supported_browser?
    end
  end

end
