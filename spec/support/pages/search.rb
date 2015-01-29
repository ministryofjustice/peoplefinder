require_relative 'base'

module Pages
  class Search < Base
    set_url_matcher(/example\.com\/$/)
  end
end
