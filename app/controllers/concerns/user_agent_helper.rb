module UserAgentHelper
  extend ActiveSupport::Concern

  Browser = Struct.new(:browser, :version)

  SUPPORTED_BROWSER_BLACKLIST = [
    Browser.new(UserAgent::Browsers::InternetExplorer.new.browser, UserAgent::Version.new('7.0'))
  ].freeze

  included do
    helper_method :unsupported_browser?, :user_agent

    def user_agent
      @ua ||= UserAgent.parse(request.user_agent)
    end

    def supported_browser?
      SUPPORTED_BROWSER_BLACKLIST.none? do |black_listed_user_agent|
        user_agent <= black_listed_user_agent
      end
    end

    def unsupported_browser?
      !supported_browser?
    end
  end

end
