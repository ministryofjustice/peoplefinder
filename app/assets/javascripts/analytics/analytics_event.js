var root;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.dispatchAnalyticsEvent = function(category, action, label) {
  if (typeof ga === 'function') {
    return ga('send', 'event', category, action, label);
  }
};

root.AnalyticsEvent = (function() {
  var bindLinks, onClick;
  bindLinks = function() {
    return $('a[data-event-category]').click(onClick);
  };
  onClick = function(event) {
    var action, category, element, label;
    element = $(event.currentTarget);
    category = element.data('event-category');
    action = element.data('event-action');
    label = element.text();
    root.dispatchAnalyticsEvent(category, action, label);
    return true;
  };
  return {
    bindLinks: bindLinks
  };
})();