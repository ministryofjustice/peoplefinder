class UserMailer < ActionMailer::Base
  default from: Rails.configuration.noreply_email

  def password_reset_notification(user)
    @user = user
    @url =  passwords_url(token: user.password_reset_token)
    mail(to: user.email,
         subject: "Your password reset request")

  end
end
