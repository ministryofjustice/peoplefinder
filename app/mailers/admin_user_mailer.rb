class AdminUserMailer < ActionMailer::Base
  default from: Rails.configuration.noreply_email

  def password_reset(password_reset)
    user = password_reset.user
    @token = password_reset.token
    mail to: user.email
  end
end
