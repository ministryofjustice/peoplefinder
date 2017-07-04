class TokenMailer < ActionMailer::Base

  layout 'email'
  add_template_helper MailHelper

  def new_token_email(token)
    @token = token
    mail to: @token.user_email
  end
end
