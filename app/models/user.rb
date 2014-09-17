User = Struct.new(:email, :name) do
  def self.from_auth_hash(auth_hash)
    email = auth_hash['info']['email']
    name = auth_hash['info']['name']

    EmailAddress.new(email).valid_domain? ? new(email, name) : nil
  end

  def self.from_token(token)
    email = token.user_email
    name = token.user_email

    EmailAddress.new(email).valid_domain? ? new(email, name) : nil
  end

  def to_s
    name || email
  end
end
