class FeedbackRequestJob < ActiveJob::Base
  queue_as :feedback_requests

  def perform(review_id)
    FeedbackRequest.new(Review.find(review_id)).send
  end
end
