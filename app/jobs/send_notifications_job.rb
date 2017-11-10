class SendNotificationsJob < ActiveJob::Base

  queue_as :send_notifications

  def perform
    NotificationSender.new.send!
  end

  def max_attempts
    3
  end

  def max_run_time
    10.minutes
  end

  def destroy_failed_jobs?
    false
  end

end
