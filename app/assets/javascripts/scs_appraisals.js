//= require environment
/* global $, config */
$(function() {
  $(document).on('click', '#invitation_status_declined', function() {
    $(this.form).find('.reason_declined_fields').removeClass('hidden');
  });

  $(document).on('click', '#invitation_status_accepted', function() {
    $(this.form).find('.reason_declined_fields').addClass('hidden');
  });

  var autosaved = function() {
    // TODO: Some kind of toast notification
  };

  $('form.autosave input, form.autosave textarea').
    on('change input', function() {
      var form = this.form;
      clearTimeout(form.autosaveTimeout);

      form.autosaveTimeout = setTimeout(function() {
        var data = $(form).serialize() + '&autosave=1';
        $.post($(form).attr('action'), data, autosaved);
      }, config.AUTOSAVE_DELAY);
    });
});
