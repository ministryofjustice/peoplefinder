class FeedbackSubmissionNotification
  def initialize(review)
    @review = review
  end

  def notify
    token = @review.subject.tokens.create!
    ReviewMailer.feedback_submission(@review, token).deliver
  end
end
