/* global $, document, TeamAutocomplete */

$(function() {
  $(document).on('click', '#add_membership', function(e) {
    e.preventDefault();
    $.ajax({
      url: this,
      success: function(data) {
        var el_to_add = $(data).html();
        $('#memberships').append(el_to_add);
        console.log($('#memberships').find('.membership').last());
        var team = new teamSelector(true, $('#memberships').find('.membership').last());
        team.initEvents();
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
});
