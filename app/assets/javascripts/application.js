/* global moj, $ */
//= require bind
//= require jquery
//= require jquery_ujs
//= require lodash
//= require govuk_toolkit
//= require moj
//= require_tree ./modules
//= require_tree ./peoplefinder
//= require Jcrop/js/jquery.Jcrop.min


$(function() {
  moj.init();

  // init the selection buttons
  moj.Helpers.selectionButtons();

});

$(function() {
  $('#problem_report_browser').val(navigator.userAgent);
  $('#new_problem_report').hide();
  $('#feedbackToggle').click(function() {
    $(this).toggleClass('open');
    $('#new_problem_report').slideToggle('slow');
  });
});


/* global $, document, teamSelector */

$(function() {
  $(document).on('click', '#add_membership', function(e) {
    e.preventDefault();
    $.ajax({
      url: this,
      success: function(data) {
        var el_to_add = $(data).html();
        $('#memberships').append(el_to_add);
        var team = new teamSelector(true, $('#memberships').find('.membership').last());
        moj.Helpers.selectionButtons();
        team.initEvents();
      }
    });
  });

  $(document).on('click', 'a.remove-new-membership', function(e) {
    e.preventDefault();
    $(this).parents('.membership').remove();
  });
});