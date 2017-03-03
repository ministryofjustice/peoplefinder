var root;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.dispatchPageView = function(url) {
  if (typeof ga === 'function') {
    return ga('send', 'pageview', url);
  }
};

root.VirtualPageview = (function() {
  var bindButtons, bindLinks, onClick;
  bindLinks = function() {
    return $('a[data-virtual-pageview]').click(onClick);
  };
  bindButtons = function() {
    return $('input.button[data-virtual-pageview]').click(onClick);
  };
  onClick = function(event) {
    var element, urls;
    element = event.currentTarget;
    urls = $(element).data('virtual-pageview').split(',');
    _.each(urls, function(url) {
      return root.dispatchPageView(url);
    });
    return true;
  };
  return {
    bindLinks: bindLinks,
    bindButtons: bindButtons
  };
})();
