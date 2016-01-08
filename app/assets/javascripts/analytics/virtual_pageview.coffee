root = exports ? this

root.dispatchPageView = (url) ->
  ga 'send', 'pageview', url if typeof ga is 'function'

root.VirtualPageview = (->
  bindLinks = ->
    $('a[data-virtual-pageview]').click onClick

  onClick = (event) ->
    element = event.currentTarget
    url = $(element).data('virtual-pageview')
    root.dispatchPageView url
    return true

  bindLinks: bindLinks
)()
