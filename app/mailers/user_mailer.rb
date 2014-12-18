class UserMailer < ActionMailer::Base
  helper :days
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

  def feedback_not_received(user, token)
    @user = user
    @token = token
    mail to: @user.email
  end

  def feedback_not_given(review, token)
    @review = review
    @token = token
    mail to: @review.author_email
  end
end
