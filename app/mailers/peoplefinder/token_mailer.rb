require 'peoplefinder'

class Peoplefinder::TokenMailer < ActionMailer::Base
  def new_token_email(token)
    @token = token
    @person = Person.find_by_email(token.user_email)

    mail(to: @token.user_email, subject: 'Access request to MOJ People Finder')  do |format|
      format.html { render layout: 'peoplefinder/email' }
      format.text
    end
  end
end
