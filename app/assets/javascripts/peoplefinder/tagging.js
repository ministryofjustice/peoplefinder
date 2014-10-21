/* global $, addToList */
$(window).load(function() {

 if($('#person_tag_chooser').length > 0)
  {
    var the_form = $('input[id=person_tags]').parents('form:first');
    var initial_tags = $('#person_tags').attr('value');
    var tag_list = $('#tag_list').attr('value').split(',');

    $('.person_tags').remove();

    // add a hidden field to store the selected tags
    $('<input>').attr({
      type: 'hidden',
      id: 'person_tags',
      name: 'person[tags]',
      value: initial_tags
    }).appendTo(the_form);

    // init the select2 widget
    $('#person_tag_chooser').select2({
      tags: tag_list,
      width: '480',
      dropdownCssClass: 'form-control',
      tokenSeparators: [','],
    });

    // set the default state of the select2 widget
    $('#person_tag_chooser').select2('val', [initial_tags]);

    // enable adding a tag with the enter key
    $('select2-search-field > input.select2-input').on('keyup', function(e) {
      if(e.keyCode === 13) { addToList($(this).val()); }
    });

    // set the hidden field when the form is submitted
    the_form.on('submit', function() {
      $('#person_tags')[0].value = $('#person_tag_chooser').select2('val');
    });
  }
});
