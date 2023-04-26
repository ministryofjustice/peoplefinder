class ApplicationMailer < Mail::Notify::Mailer
  layout 'email'

  def sendmail(**args)
    view_mail('00b59047-6493-450d-833f-14ffe9136356', args)
  end
end
