require 'peoplefinder'

class Peoplefinder::TokenMailer < ActionMailer::Base
  layout 'peoplefinder/email'

  def new_token_email(token)
    @token = token

    mail to: @token.user_email
  end
end
