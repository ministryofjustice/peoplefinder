module Pages
  class UnsupportedBrowser < Base
    set_url '/unsupported_browser'

    element :unsupported_browser_warning, '.cb-unsupported-browser-warning'
    element :unsupported_browser_continue_link, 'a[href="/unsupported_browser/continue"]'
  end
end
