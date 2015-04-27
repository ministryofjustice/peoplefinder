/* global $ */

$(function() {
  $('#feedback_environment').val(navigator.userAgent);
  $('#feedback_time').val(Date);
  $('#feedback').hide();
  $('#feedbackToggle').click(function(e){
    $(this).toggleClass('open');
    $('#feedback').slideToggle('slow');
  });
});
