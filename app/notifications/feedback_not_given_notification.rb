class FeedbackNotGivenNotification
  def initialize(review)
    @review = review
  end

  def notify
    token = @review.tokens.create!
    UserMailer.feedback_not_given(@review, token).deliver
  end
end
