
if ENV['INTERCEPTED_EMAIL_RECIPIENT'].present?
  def login_subject_text
    I18n.t('token_mailer.new_token_email.subject')
  end

  if login_subject_text[/translation missing/]
    I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
    I18n.default_locale = :en
    I18n.reload!
  end

  ActionMailer::Base.register_interceptor OnlySendLoginEmailInterceptor.new(
    ENV['INTERCEPTED_EMAIL_RECIPIENT'],
    subject_prefix: "[#{ENV['ENV']}]".upcase,
    login_email_subject: login_subject_text
  )
end
