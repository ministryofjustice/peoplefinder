class ClosureMailingJob < ActiveJob::Base
  queue_as :closure_mailings

  def perform
    ReviewPeriod.instance.send_closure_notifications
  end
end
