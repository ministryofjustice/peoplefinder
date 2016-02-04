require 'mail'
require 'recipient_interceptor'

class OnlySendLoginEmailInterceptor

  attr_reader :login_email_subject

  def initialize recipient_string, subject_prefix:, login_email_subject:
    @subject_prefix = subject_prefix
    @interceptor = RecipientInterceptor.new(recipient_string,
      subject_prefix: subject_prefix)
    @login_email_subject = login_email_subject
  end

  def delivering_email message
    if login_email? message
      message.subject = "#{@subject_prefix} #{message.subject}" if @subject_prefix
    else
      @interceptor.delivering_email(message) unless login_email? message
    end
  end

  private

  def login_email? message
    message.subject == @login_email_subject
  end

end
