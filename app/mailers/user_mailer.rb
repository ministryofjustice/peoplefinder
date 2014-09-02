class UserMailer < ActionMailer::Base
  default from: Rails.configuration.noreply_email

  def introduction(user, token)
    @user = user
    @token = token
    mail to: @user.email
  end

  def closure_notification(user, token)
    @user = user
    @token = token
    mail to: @user.email
  end
end
