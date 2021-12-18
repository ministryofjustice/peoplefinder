class TokenMailer < ApplicationMailer

  # layout 'email'
  helper MailHelper

  def new_token_email(token)
    @token = token
    mail(to: @token.user_email) do |format|
      if @token.user_email.include?('@probation.gsi')
        headers['skip_premailer'] = true
        format.text
      else
        format.text
        format.html
      end
    end
  end
end
