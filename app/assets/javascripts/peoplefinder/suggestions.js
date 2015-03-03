/* global $ */
$(function() {
  'use strict';

  var $form    = $('form.new_suggestion');
  var $submit  = $form.find('.submit-button');
  var booleans = [
    'missing_fields', 'incorrect_fields', 'duplicate_profile',
    'inappropriate_content', 'person_left'
  ];

  // Show or hide the submit button based on checked fields
  // Show if any are checked, hide if all unchecked
  var showHideSubmit = function() {
    $submit.hide();
    for (var i in booleans) {
      var field = booleans[i];
      if ($form.find('input[name="suggestion[' + field + ']"]').
                is(':checked')) {
        $submit.show();
      }
    }
  };

   // Show or hide the extra info fields for all checkboxes
   // Show if it's checked, hide if unchecked
  var showHideInfo = function() {
    $form.find('input[type="checkbox"]').each(function() {
      var $checkbox = $(this);
      var targetSelector = $checkbox.attr('target');
      if ($checkbox.is(':checked')) {
        $(targetSelector).show();
      } else {
        $(targetSelector).hide();
      }
    });
  };

  var updateForm = function() {
    showHideSubmit();
    showHideInfo();
  };

  // Update the form when any input on the form changes
  $form.on('change', 'input', updateForm);

  // Update the form on page load
  updateForm();

});
