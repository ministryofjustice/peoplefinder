moj.Modules.search = {
  init: function() {

    $('#mod-search-input').on('click focus blur', function(e) {
      var $el = $(e.target);
      return moj.Helpers.searchInput($el);
    })

    $('#mod-search-input').is(function(idx, el) {
      var $el = $(el);
      return moj.Helpers.searchInput($el);
    });
  }
}
