class DeclineNotificationJob < ActiveJob::Base
  queue_as :decline_notifications

  def perform(review_id)
    DeclineNotification.new(Review.find(review_id)).send
  end
end
