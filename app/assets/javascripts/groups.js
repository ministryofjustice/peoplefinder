$(function() {
  return $(document).on("click", "#add_another_group", function(e) {
    e.preventDefault();
    return $.ajax({
      url: '/groups/add_membership',
      success: function(data) {
        var el_to_add;
        el_to_add = $(data).html();
        return $('#memberships').append(el_to_add);
      },
      error: function(data) {
        return alert("Sorry, There Was An Error!");
      }
    });
  });
});
