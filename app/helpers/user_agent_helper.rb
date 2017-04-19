module UserAgentHelper

  Browser = Struct.new(:browser, :version)

  OLD_BROWSERS = [
    Browser.new('Internet Explorer','7.0'),
    Browser.new('Internet Explorer','6.0')
  ]

  def user_agent
    UserAgent.parse(request.user_agent)
  end

  def unsupported_browser?
    OLD_BROWSERS.detect { |browser| user_agent <= browser }
  end

end
