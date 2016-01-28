if ENV['INTERCEPTED_EMAIL_RECIPIENT'].present?
  ActionMailer::Base.register_interceptor OnlySendLoginEmailInterceptor.new(
    ENV['INTERCEPTED_EMAIL_RECIPIENT'],
    subject_prefix: "[#{ENV['ENV']}]".upcase,
    login_email_subject: I18n.t('token_mailer.new_token_email.subject')
  )
end
