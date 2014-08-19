/* global $, document, peoplefinderApp */
$(function() {
  $(document).on('click', '#add_membership', function(e) {
    e.preventDefault();
    $.ajax({
      url: this,
      success: function(data) {
        var el_to_add = $(data).html();
        $('#memberships').append(el_to_add);
        // HACK: Rather than looking up the last element, we should be able to
        // use the content we're dynamically appending.
        var browsers = $('.org-browser');
        var container = browsers[browsers.length - 1];
        peoplefinderApp.injectNewContainer(container);
      }
    });
  });

  $(document).on('click', 'a.remove-new-membership', function(e) {
    e.preventDefault();
    $(this).parents('.membership').remove();
  });

  $(document).on('click', 'a.show-role-editable', function(e) {
    e.preventDefault();
    $(this).closest('.role-summary').hide();
    $(this).closest('.membership').children('.editable-fields').show();
  });

  $(document).on('click', 'a.show-parent-editable', function(e) {
    e.preventDefault();
    $(this).closest('.parent-summary').hide();
    $(this).closest('.group-parent').children('.editable-fields').show();
  });
});
