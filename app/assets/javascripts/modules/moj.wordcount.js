/* global jQuery */
jQuery(function ($){
  'use strict';

  var $limitedTextAreas = $('textarea[data-limit]');
  if( $limitedTextAreas.length > 0 ){
    $limitedTextAreas.each(function (i, o){
      var updateCounter = function (){
        var charsLeft = limit - $textarea.val().length;

        if( charsLeft > 0 ){
          $counterBox.removeClass('error');
          $counter.html( '(' + charsLeft + ' remaining)');
        }else {
          $counterBox.addClass('error');
          $counter.html('(' + (charsLeft * -1) + ' extra)');
        }
      };

      var $textarea = $(o);
      var limit = $textarea.data('limit');
      var $counterBox = $(
        '<p class="textarea-word-count form-hint">' +
        'Maximum ' + limit + ' characters, including spaces. ' +
        '<span class="chars-remaining">(' + limit + ' remaining)</span>' +
        '<p/>'
      );

      var $counter = $counterBox.find('.chars-remaining');
      $textarea.after($counterBox);

      updateCounter();
      $textarea.keyup(updateCounter);
    });
  }
});
