/* jslint browser: true */
/* global $ */
(function(){
  var makeCloneable = function(selector) {
    var scope = $(selector);

    var update_remove_one_visibility = function() {
      var hidden = scope.find('.cloneable').length < 2;
      scope.find('.remove-one').toggleClass('hidden', hidden);
    };

    update_remove_one_visibility();

    scope.find('.add-one').click(function(e) {
      e.preventDefault();

      var newContent = scope.find('.cloneable:first').clone();
      scope.find('.cloneable:last').after(newContent);

      scope.find('.cloneable:last input[type="text"]').val('');
      update_remove_one_visibility();
    });

    scope.find('.remove-one').click(function(e) {
      e.preventDefault();

      scope.find('.cloneable:last').remove();
      update_remove_one_visibility();
    });
  };

  $(document).ready(function() {
    makeCloneable('#budgetary-responsibilities');
  });
})();
