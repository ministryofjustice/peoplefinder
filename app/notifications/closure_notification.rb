class ClosureNotification
  def initialize(user)
    @user = user
  end

  def notify
    token = @user.tokens.create!
    UserMailer.closure_notification(@user, token).deliver
  end
end
