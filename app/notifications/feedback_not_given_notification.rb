class FeedbackNotGivenNotification
  def initialize(review)
    @review = review
  end

  def notify
    email = @review.author_email
    Rails.logger.info "Sending Feedback Not Received notification to #{email}"
    token = @review.tokens.create!
    UserMailer.feedback_not_given(@review, token).deliver
  end
end
