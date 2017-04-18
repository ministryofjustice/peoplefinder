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

// Eliminate console spam in test output
moj.log = function() {};

moj.Helpers.searchInput = function ($el) {
  return !!$el.val() ? $el.addClass('focus') : $el.removeClass('focus');
}

$(function() {
  moj.init();

  var $buttons = $("label input[type='radio'], label input[type='checkbox']");
  var selectionButtons = new GOVUK.SelectionButtons($buttons);


  $('#mod-search-input').on('click focus blur', function(e){
    var $el = $(e.target);
    return moj.Helpers.searchInput($el);
  })

  $('#mod-search-input').is(function (idx, el) {
    var $el = $(el);
    return moj.Helpers.searchInput($el);
  });

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
        team.initEvents();
      }
    });
  });

  $(document).on('click', 'a.remove-new-membership', function(e) {
    e.preventDefault();
    $(this).parents('.membership').remove();
  });
});