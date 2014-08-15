/* global $, document */
$(function() {
  $(document).on('click', '#add_membership', function(e) {
    e.preventDefault();
    $.ajax({
      url: this,
      success: function(data) {
        var el_to_add;
        el_to_add = $(data).html();
        $('#memberships').append(el_to_add);
      }
    });
  });
});

$(function() {
  $(document).on('click', 'a.remove-new-membership', function(e) {
    e.preventDefault();
    $(this).parents('.membership').remove();
  });
});

$(function() {
  $(document).on('click', 'a.show-role-editable', function(e) {
     e.preventDefault();
     $(this).closest('.role-summary').hide();
     $(this).closest('.membership').children('.editable-fields').show();
   });
})
