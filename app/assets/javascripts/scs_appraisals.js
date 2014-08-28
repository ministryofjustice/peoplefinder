/* global $ */
$(function() {
  $(document).on('click', '#feedback_request_status_reject', function() {
    $(this.form).find('.rejection_reason_fields').removeClass('hidden');
  });

  $(document).on('click', '#feedback_request_status_accept', function() {
    $(this.form).find('.rejection_reason_fields').addClass('hidden');
  });
});
