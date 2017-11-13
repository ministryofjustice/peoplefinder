class SendNotificationsJob < ActiveJob::Base

  queue_as :send_notifications

  def perform
    notify_people!
    notify_geckoboard!
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

  def notify_people!
    NotificationSender.new.send!
  end

  def notify_geckoboard!
    GeckoboardPublisher::PhotoProfilesReport.new.publish!(true)
    GeckoboardPublisher::ProfilesPercentageReport.new.publish!(true)
    GeckoboardPublisher::TotalProfilesReport.new.publish!(true)
    GeckoboardPublisher::ProfilesChangedReport.new.publish!(true)
    GeckoboardPublisher::ProfileCompletionsReport.new.publish!(true)
  end

end
