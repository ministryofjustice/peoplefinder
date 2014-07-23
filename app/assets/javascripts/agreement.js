/* jslint browser: true */
/* global $ */
(function(){
  var makeCloneable = function(selector) {
    $(selector).each(function(_, element) {
      var scope = $(element);

      var update_remove_one_visibility = function() {
        var hidden = scope.find('.cloneable-item').length < 2;
        scope.find('.remove-one').toggleClass('hidden', hidden);
      };

      update_remove_one_visibility();

      scope.find('.add-one').click(function(e) {
        e.preventDefault();

        var newContent = scope.find('.cloneable-item:first').clone();
        scope.find('.cloneable-item:last').after(newContent);

        scope.find('.cloneable-item:last input[type="text"]').val('');
        scope.find('.cloneable-item:last textarea').text('');
        update_remove_one_visibility();
      });

      scope.find('.remove-one').click(function(e) {
        e.preventDefault();

        scope.find('.cloneable-item:last').remove();
        update_remove_one_visibility();
      });
    });
  };

  $(document).ready(function() {
    makeCloneable('.cloneable');
  });
})();
