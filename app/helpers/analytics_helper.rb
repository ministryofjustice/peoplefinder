module AnalyticsHelper
  def search_result_analytics_attributes(index)
    pageview_path = index < 3 ? '/top-3-search-result' : '/below-top-3-search-result'
    {
      'virtual-pageview': "/search-result,#{pageview_path}",
      'event-category': 'Search result click',
      'event-action': "Click result #{'%03d' % (index + 1)}"
    }
  end

  def token_request_analytics_attributes
    {
      'virtual-pageview': '/sessions/token-request'
    }
  end

  def edit_profile_analytics_attributes(person_id = nil)
    {
      'virtual-pageview': '/people/edit-click',
      'event-category': 'Edit profile click',
      'event-action': "Click edit person #{person_id}"
    }
  end
end
