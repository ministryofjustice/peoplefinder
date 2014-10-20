/* global $, document, peoplefinderApp */
//= require peoplefinder/peoplefinder_app

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

  $(document).on('click', 'a.show-editable-fields', function(e) {
    e.preventDefault();
    $(this).closest('.editable-summary').hide();
    $(this).closest('.editable-container').children('.editable-fields').show();
  });

  $(document).on('click', '#person_no_phone', function() {
    $('#person_primary_phone_number').val('');
    $('#person_secondary_phone_number').val('');
    $('.phone_numbers').toggle();
  });

  $(window).load(function() {
    var the_form = $('input[id=person_tags]').parents('form:first')

    // remove the non-js default field
    $('.person_tags').remove();

    // add a hidden field
    $('<input>').attr({
      type: 'hidden',
      id: 'person_tags',
      name: 'person[tags]'
    }).appendTo(the_form);

    $('#person_tag_chooser').select2({
      tags: [],
      width: '480',
      dropdownCssClass: 'form-control',
      tokenSeparators: [','],

    }).on('select2-blur', function(e) {
      e.preventDefault();
      $('#person_tags')[0].value = $(this).select2('val');

    });

    $('#person_tag_chooser').select2('val', [$('#person_tags').attr('value')]);

    $('select2-search-field > input.select2-input').on('keyup', function(e) {
      if(e.keyCode === 13) addToList($(this).val());
    });
  });
});
