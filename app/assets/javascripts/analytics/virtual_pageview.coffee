root = exports ? this

root.dispatchPageView = (url) ->
  ga 'send', 'pageview', url if typeof ga is 'function'

root.VirtualPageview = (->
  bindLinks = ->
    $('a[data-virtual-pageview]').click onClick

  bindButtons = ->
   $('input.button[data-virtual-pageview]').click onClick

  onClick = (event) ->
    element = event.currentTarget
    urls = $(element).data('virtual-pageview').split(',')
    _.each urls, (url) ->
      root.dispatchPageView url
    return true

  bindLinks: bindLinks
  bindButtons: bindButtons
)()
