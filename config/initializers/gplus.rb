class OmniAuth::Strategies::GPlus
  OPENID_CONNECT_SCOPES = %w[ profile email openid ]

  def format_scope(scope)
    if OPENID_CONNECT_SCOPES.include?(scope)
      scope
    else
      "https://www.googleapis.com/auth/#{scope}"
    end
  end
end
