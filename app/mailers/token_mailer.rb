class TokenMailer < ActionMailer::Base
  layout 'email'

  def new_token_email(token)
    @token = token

    mail to: @token.user_email
  end
end
