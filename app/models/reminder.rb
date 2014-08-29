class Reminder
  def initialize(review)
    @review = review
  end

  def send
    token = @review.tokens.create!
    ReviewMailer.feedback_request(@review, token).deliver
  end
end
