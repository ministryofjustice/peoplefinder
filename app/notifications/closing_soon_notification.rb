class ClosingSoonNotification
  def initialize(user)
    @user = user
  end

  def notify
    email = @user.email
    Rails.logger.info "Sending Closing Soon notification to #{email}"
    token = @user.tokens.create!
    UserMailer.closing_soon(@user, token).deliver
  end
end
