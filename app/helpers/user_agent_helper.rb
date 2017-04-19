module UserAgentHelper
  Browser = Struct.new(:browser, :version)

  SUPPORTED_BROWSERS = [
      Browser.new('Safari', '6.0'),
      Browser.new('Firefox', '19.0'),
      Browser.new('Internet Explorer', '8.0'),
      Browser.new('Chrome', '25.0'),
  ].freeze

  def user_agent
    @ua ||= UserAgent.parse(request.user_agent)
  end

  def supported_browser?
    # ap "<<<<<<<<<<<< LINE #{__LINE__} #{user_agent.browser}:#{user_agent.version}>>>>>>>>>>>>>>"
    SUPPORTED_BROWSERS.any? do |browser|
      user_agent >= browser
    end
  end

  def unsupported_browser?
    !supported_browser?
  end

end
