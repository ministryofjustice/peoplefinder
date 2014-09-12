//= require environment
/* global $, config */
$(function() {
  $(document).on('click', '#invitation_status_declined', function() {
    $(this.form).find('.reason_declined_fields').removeClass('hidden');
  });

  $(document).on('click', '#invitation_status_accepted', function() {
    $(this.form).find('.reason_declined_fields').addClass('hidden');
  });

  var autosave = function(form) {
    autosaveStarted();
    var data = $(form).serialize() + '&autosave=1';
    $.post($(form).attr('action'), data).
      done(autosaveSucceeded).
      fail(autosaveFailed);
  };

  var indicate = function(name) {
    $('.autosave-status .indicator').hide();
    if (name) { $('.autosave-status .' + name).show(); }
  };

  var autosaveNeeded = function() {
    indicate('needed');
  };

  var autosaveStarted = function() {
    indicate('saving');
  };

  var autosaveSucceeded = function() {
    indicate('saved');
  };

  var autosaveFailed = function() {
    indicate('failed');
  };

  var refreshRadioStyles = function() {
    $('input:radio').parent().removeClass('selected');
    $('input:radio:checked').parent().addClass('selected');
  };

  $('form.autosave input, form.autosave textarea').
    on('change input', function() {
      refreshRadioStyles();
      var form = this.form;
      autosaveNeeded();
      clearTimeout(form.autosaveTimeout);
      form.autosaveTimeout = setTimeout(function() {
        autosave(form);
      }, config.AUTOSAVE_DELAY);
    });

  refreshRadioStyles();
});
