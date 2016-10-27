module AnalyticsHelper
  def search_result_analytics_attributes(index)
    pageview_path = index < 3 ? '/top-3-search-result' : '/below-top-3-search-result'
    {
      'virtual-pageview': "/search-result,#{pageview_path}",
      'event-category': 'Search result click',
      'event-action': "Click result #{'%03d' % (index + 1)}"
    }
  end

  def request_token_analytics_attributes
    {
      'virtual-pageview': '/token-request',
      'event-category': 'Tokens',
      'event-action': 'Click request link'
    }
  end

  def spend_token_analytics_attributes
    {
      'virtual-pageview': '/token-spend',
      'event-category': 'Tokens',
      'event-action': 'Click token link in email'
    }
  end
end
