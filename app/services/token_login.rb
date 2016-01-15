require 'secure'

class TokenLogin

  def initialize(token_value)
    @token_value = token_value
  end

  def call view
    token = find_token_securely
    if token.nil?
      view.render_new_sessions_path_with_invalid_token
    elsif token.active?
      login(view, token)
    else
      view.render_new_sessions_path_with_expired_token
    end
  end

  private

  def find_token_securely
    Token.find_each do |token|
      return token if Secure.compare(token.value, @token_value)
    end
  end

  def login view, token
    person = FindCreatePerson.from_token(token)
    view.login_and_render(person)
    token.spend!
  end

end
