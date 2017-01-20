require 'secure'

class TokenLogin

  attr_reader :token

  def initialize(token_value)
    @token_value = token_value
    @token = find_token_securely
  end

  def call view
    if token && token.active?
      login_and_render(view)
    else
      view.render_new_sessions_path_with_expired_token_message
    end
  end

  private

  def find_token_securely
    Token.find_each do |token|
      return token if Secure.compare(token.value, @token_value)
    end
  end

  def login_and_render view
    person = view.person_from_token(token)
    view.render_or_redirect_login person
    token.spend!
  end

end
