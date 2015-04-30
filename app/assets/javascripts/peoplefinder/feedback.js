/* global $ */

$(function() {
  $('#problem_report_browser').val(navigator.userAgent);
  $('#new_problem_report').hide();
  $('#feedbackToggle').click(function(){
    $(this).toggleClass('open');
    $('#new_problem_report').slideToggle('slow');
  });
});
