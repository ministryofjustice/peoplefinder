class FeedbackSubmissionJob
  queue_as :feedback_submissions

  def perform(review_id)
    FeedbackSubmissionNotification.new(Review.find(review_id)).send
  end
end
