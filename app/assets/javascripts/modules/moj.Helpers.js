(function() {
  'use strict';

  moj.Helpers = {
    searchInput: function($el) {
      return !!$el.val() ? $el.addClass('focus') : $el.removeClass('focus');
    },
    selectionButtons: function () {
      var $buttons = $("label input[type='radio'], label input[type='checkbox']");
      var selectionButtons = new GOVUK.SelectionButtons($buttons);
    }
  }

}());
