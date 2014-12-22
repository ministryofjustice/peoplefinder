class ClosingSoonNotification
  def initialize(user)
    @user = user
  end

  def notify
    token = @user.tokens.create!
    UserMailer.closing_soon(@user, token).deliver
  end
end
