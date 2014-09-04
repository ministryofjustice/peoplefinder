/* global $, config */
$(function() {
  $(document).on('click', '#invitation_status_rejected', function() {
    $(this.form).find('.rejection_reason_fields').removeClass('hidden');
  });

  $(document).on('click', '#invitation_status_accepted', function() {
    $(this.form).find('.rejection_reason_fields').addClass('hidden');
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
