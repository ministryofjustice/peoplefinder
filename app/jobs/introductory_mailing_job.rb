class IntroductoryMailingJob < ActiveJob::Base
  queue_as :introductory_mailings

  def perform
    ReviewPeriod.send_introductions
  end
end
