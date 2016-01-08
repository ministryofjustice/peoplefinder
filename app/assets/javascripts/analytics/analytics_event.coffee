root = exports ? this

root.dispatchAnalyticsEvent = (category, action, label) ->
  ga 'send', 'event', category, action, label if typeof ga is 'function'

root.AnalyticsEvent = (->
  bindLinks = ->
    $('a[data-event-category]').click onClick

  onClick = (event) ->
    element = $(event.currentTarget)
    category = element.data('event-category')
    action = element.data('event-action')
    label = element.text()

    root.dispatchAnalyticsEvent(category, action, label)
    return true

  bindLinks: bindLinks
)()
