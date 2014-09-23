//= require environment
/* global window, $, config */
$(function() {
  $('form.edit_invitation input').on('change', function() {
    var isDeclined = $(this.form).find('input:checked').val() === 'declined';
    var reason = $(this.form).find('.reason_declined_fields');
    reason.removeClass('hidden');
    if (isDeclined) { reason.show(); } else { reason.hide(); }
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
    $('input:radio').parents('.block-label').removeClass('selected');
    $('input:radio:checked').parents('.block-label').addClass('selected');
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

  $('.print-button').on('click', function() { window.print(); });
});
