class Token < ActiveRecord::Base
  include Concerns::Sanitizable
  sanitize_fields :user_email, strip: true, downcase: true
  after_create :deactivate_tokens

  after_initialize :generate_value

  validate :valid_email_address

  DEFAULT_TTL = 10_800

  def to_param
    value
  end

  def valid_email_address
    if !EmailAddress.new(user_email).valid_format?
      errors.add(:user_email, :invalid_address)
    elsif !EmailAddress.new(user_email).valid_domain?
      errors.add(:user_email, :invalid_domain)
    end
  end

  def self.for_person(person)
    Token.create!(user_email: person.email)
  end

  def active?
    (created_at > ttl.seconds.ago) && !spent?
  end

  def self.ttl
    Rails.configuration.try(:token_ttl) || DEFAULT_TTL
  end

  def ttl
    self.class.ttl
  end

  def spend!
    update_attributes!(spent: true)
  end

private

  def deactivate_tokens
    Token.where(spent: false, user_email: user_email).each do |token|
      token.spend! if token != self
    end
  end

  def generate_value
    self.value ||= SecureRandom.uuid
  end
end
