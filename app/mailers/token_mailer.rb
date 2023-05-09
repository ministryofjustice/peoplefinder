class TokenMailer < GovukNotifyRails::Mailer
  def new_token_email(token)
    set_template('new_token')

    set_personalisation(
      token_url: token_url(token),
    )

    mail(to: token.user_email)
  end
end
