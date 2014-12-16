class FeedbackSubmissionJob < ActiveJob::Base
  queue_as :feedback_submissions

  def perform(review_id)
    FeedbackSubmissionNotification.new(Review.find(review_id)).notify
  end
end
