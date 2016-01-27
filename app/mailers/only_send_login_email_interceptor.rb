require 'mail'
require 'recipient_interceptor'

class OnlySendLoginEmailInterceptor

  attr_reader :login_email_subject

  def initialize recipient_string, subject_prefix:, login_email_subject:
    @interceptor = RecipientInterceptor.new(recipient_string,
      subject_prefix: subject_prefix)
    @login_email_subject = login_email_subject
  end

  def delivering_email message
    @interceptor.delivering_email(message) unless login_email? message
  end

  private

  def login_email? message
    message.subject == @login_email_subject
  end

end
