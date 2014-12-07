class FeedbackSubmissionNotification
  def initialize(review)
    @review = review
  end

  def send
    token = @review.tokens.create!
    ReviewMailer.feedback_submission(@review, token).deliver
  end
end
