/* global $, document, TeamAutocomplete */

$(function() {
  $(document).on('click', '#add_membership', function(e) {
    e.preventDefault();
    $.ajax({
      url: this,
      success: function(data) {
        var el_to_add = $(data).html();
        $('#memberships').append(el_to_add);
        TeamAutocomplete
          .enhance( $('.team-select')
          .not('.team-select-enhanced')[0]);
      }
    });
  });

  $(document).on('click', 'a.remove-new-membership', function(e) {
    e.preventDefault();
    $(this).parents('.membership').remove();
  });

  $(document).on('click', 'a.show-editable-fields, .editable-summary', function(e) {
    e.preventDefault();
    // $(this).closest('.editable-summary').hide();
    $(this).closest('.editable-container').find('a.show-editable-fields').hide();
    $(this).closest('.editable-container').children('.editable-fields').show();
  });

  $(document).on('click', 'a.hide-editable-fields', function(e){
    e.preventDefault();
    $(this).closest('.editable-container').find('a.show-editable-fields').show();
    $(this).closest('.editable-container').children('.editable-fields').hide();
  });
});
