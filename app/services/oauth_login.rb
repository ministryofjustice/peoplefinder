class OauthLogin

  attr_reader :auth_hash

  def initialize(auth_hash)
    @auth_hash = auth_hash
  end

  def call view
    login_and_render(view)
  end

  private

  def login_and_render view
    person = view.person_from_oauth(auth_hash)
    view.render_or_redirect_login person
  end

end
