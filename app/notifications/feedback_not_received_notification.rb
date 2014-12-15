class FeedbackNotReceivedNotification
  def initialize(user)
    @user = user
  end

  def notify
    token = @user.tokens.create!
    UserMailer.feedback_not_received(@user, token).deliver
  end
end
