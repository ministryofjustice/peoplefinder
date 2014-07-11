class User < ActiveRecord::Base
  validate :validate_email_domain
  validate :email, presence: true, unique: true

  def self.for_email(email)
    user = User.where(email: email).first_or_create
  end

  def self.from_auth_hash(auth_hash)
    email = normalize_email(auth_hash['info']['email'])
    name = auth_hash['info']['name']

    user = User.for_email(email)
    return nil unless user.valid?
    user.update_name(name)
    user
  end

  def self.normalize_email(e)
    Mail::Address.new(e).address.downcase
  end

  def to_s
    name || email
  end

  def email=(e)
    super User.normalize_email(e)
  end

  def update_name(n)
    update_attribute :name, n unless self.name == n
  end

  def domain
    Mail::Address.new(email).domain
  end

private
  def validate_email_domain
    valid_domains = Rails.configuration.valid_login_domains
    unless valid_domains.include?(domain)
      errors.add :email, "must be in the list of permitted domains"
    end
  end
end
