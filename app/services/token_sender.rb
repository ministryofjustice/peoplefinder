require 'secure'

class TokenSender

  attr_reader :user_email_error

  REPORT_EMAIL_ERROR_REGEXP = %r{(not formatted correctly|reached the limit)}

  def initialize(user_email)
    @user_email = user_email
  end

  def token
    token = Token.find_by_user_email(@user_email)
    if token && token.active?
      token
    else
      token = Token.new(user_email: @user_email)
      if token.save
        token
      else
        @user_email_error = token.errors[:user_email].first
        nil
      end
    end
  end

  def report_user_email_error?
    @user_email_error[REPORT_EMAIL_ERROR_REGEXP]
  end

end
