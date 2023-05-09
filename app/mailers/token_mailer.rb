class TokenMailer < GovukNotifyRails::Mailer
  def new_token_email(token)
    set_template('539c30de-c483-4002-b7b1-b84d1bbaa6ac')

    set_personalisation(
      token_url: token_url(token),
    )

    mail(to: token.user_email)
  end
end
