class TokenMailer < ActionMailer::Base

  layout 'email'
  add_template_helper MailHelper

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
