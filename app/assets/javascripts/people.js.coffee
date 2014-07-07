$ ->
  $(document).on "click", "#add_membership", (e) ->
    e.preventDefault();
    $.ajax
      url: '/people/add_membership'
      success: (data) ->
        el_to_add = $(data).html()
        $('#memberships').append(el_to_add)
      error: (data) ->
        alert "Sorry, There Was An Error!"