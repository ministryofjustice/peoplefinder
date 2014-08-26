class Introduction
  def initialize(user)
    @user = user
  end

  def send
    token = @user.tokens.create!
    UserMailer.introduction(@user, token).deliver
  end
end
