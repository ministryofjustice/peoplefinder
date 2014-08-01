class UserMailer < ActionMailer::Base
  default from: Rails.configuration.noreply_email

  def password_reset_notification(user)
    @user = user
    @url =  passwords_url(token: user.token)
    mail to: user.email
  end

  def registration_notification(user)
    @user = user
    @url = new_registration_url(token: user.token)
    mail to: user.email
  end
end
