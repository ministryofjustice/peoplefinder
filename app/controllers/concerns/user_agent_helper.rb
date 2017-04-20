module UserAgentHelper
  extend ActiveSupport::Concern

  Browser = Struct.new(:browser, :version)

  SUPPORTED_BROWSERS = [
    Browser.new('Safari', '4.0'),
    Browser.new('Firefox', '19.0'),
    Browser.new('Internet Explorer', '8.0'),
    Browser.new('Chrome', '25.0')
  ].freeze

  included do
    helper_method :unsupported_browser?

    def user_agent
      @ua ||= UserAgent.parse(request.user_agent)
    end

    def supported_browser?
      SUPPORTED_BROWSERS.any? do |browser|
        user_agent >= browser
      end
    end

    def unsupported_browser?
      !supported_browser?
    end
  end

end
