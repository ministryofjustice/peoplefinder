class TokenMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def new_token_email
    TokenMailer.new_token_email token
  end

  private

  def token
    Token.new(user_email: recipient.email)
  end

end
