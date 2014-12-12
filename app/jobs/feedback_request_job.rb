class FeedbackRequestJob < ActiveJob::Base
  queue_as :feedback_requests

  def perform(review_id)
    FeedbackRequestNotification.new(Review.find(review_id)).notify
  end
end
