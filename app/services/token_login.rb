class TokenLogin

  attr_reader :token

  def initialize(token_value)
    @token = find_token_securely token_value
  end

  def call view
    if token && token.active?
      if view.supported_browser?
        login_and_render(view)
      else
        view.redirect_to_unsupported_browser_warning
      end
    else
      view.render_new_sessions_path_with_expired_token_message
    end
  end

  private

  def find_token_securely token_value
    Token.find_securely token_value
  end

  def login_and_render view
    person = view.person_from_token(token)
    view.render_or_redirect_login person
    token.spend!
  end

end
