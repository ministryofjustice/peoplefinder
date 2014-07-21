class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def password_reset_notification(user)
    @user = user
    @url =  passwords_path(user.password_reset_token)
    mail(to: user.email,
         subject: "Your password reset request")

  end
end
