/* global $ */
$(function() {
  $(document).on('click', '#submission_status_rejected', function() {
    $(this.form).find('.rejection_reason_fields').removeClass('hidden');
  });

  $(document).on('click', '#submission_status_accepted', function() {
    $(this.form).find('.rejection_reason_fields').addClass('hidden');
  });
});
