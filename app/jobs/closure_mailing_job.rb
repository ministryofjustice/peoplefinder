class ClosureMailingJob < ActiveJob::Base
  queue_as :closure_mailings

  def perform
    ReviewPeriod.send_closure_notifications
  end
end
