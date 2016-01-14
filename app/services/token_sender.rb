require 'secure'

class TokenSender

  attr_reader :user_email_error

  REPORT_EMAIL_ERROR_REGEXP = %r{(not formatted correctly|reached the limit)}

  def initialize(user_email)
    @user_email = user_email
  end

  def call view
    token = obtain_token
    if token
      TokenMailer.new_token_email(token).deliver_later
      view.render_create_view token: token
    elsif report_user_email_error?
      view.render_new_view user_email_error: user_email_error
    else
      view.render_create_view token: nil
    end
  end

  def obtain_token
    token = build_token
    if token.save
      token
    else
      @user_email_error = token.errors[:user_email].first
      nil
    end
  end

  private

  def report_user_email_error?
    user_email_error[REPORT_EMAIL_ERROR_REGEXP]
  end

  def build_token
    token = Token.find_by_user_email(@user_email)
    if token && token.active?
      Token.new(user_email: @user_email, value: token.value)
    else
      Token.new(user_email: @user_email)
    end
  end

end
