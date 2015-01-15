class FeedbackNotReceivedNotification
  def initialize(user)
    @user = user
  end

  def notify
    email = @user.email
    Rails.logger.info "Sending Feeback Not Received notification to #{email}"
    token = @user.tokens.create!
    UserMailer.feedback_not_received(@user, token).deliver
  end
end
