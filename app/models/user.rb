User = Struct.new(:email, :name) do
  def self.from_auth_hash(auth_hash)
    email = auth_hash['info']['email']
    name = auth_hash['info']['name']

    addr = Mail::Address.new(email)
    valid_domains = Rails.configuration.valid_login_domains

    return nil unless valid_domains.include?(addr.domain)

    new(email, name)
  end

  def to_s
    name || email
  end
end
