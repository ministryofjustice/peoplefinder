require 'peoplefinder'

class Peoplefinder::TokenMailer < ActionMailer::Base
  def new_token_email(token)
    @token = token
    mail to: @token.user_email, subject: 'Access request to MOJ People Finder'
  end
end
