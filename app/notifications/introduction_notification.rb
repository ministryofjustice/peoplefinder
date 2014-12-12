class IntroductionNotification
  def initialize(user)
    @user = user
  end

  def notify
    token = @user.tokens.create!
    UserMailer.introduction(@user, token).deliver
  end
end
