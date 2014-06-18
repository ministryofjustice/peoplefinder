User = Struct.new(:email) do
  def self.from_auth_hash(auth_hash)
    email = auth_hash['info']['email']
    domain = email.split(/@/, 2)[1]
    valid_domains = Rails.configuration.valid_login_domains

    return nil unless valid_domains.include?(domain)

    new(email)
  end

  def to_s
    email
  end
end
