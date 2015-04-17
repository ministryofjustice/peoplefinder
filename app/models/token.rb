class Token < ActiveRecord::Base
  include Concerns::Sanitizable
  MaxNumberOfTokensError = Class.new(StandardError)

  sanitize_fields :user_email, strip: true, downcase: true
  before_create :throttle_check
  after_create :deactivate_tokens

  after_initialize :generate_value

  validate :valid_email_address

  DEFAULT_TTL = 10_800
  DEFAULT_MAX_TOKENS_PER_HOUR = 8

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

  def self.max_tokens_per_hour
    Rails.configuration.try(:max_tokens_per_hour) || DEFAULT_MAX_TOKENS_PER_HOUR
  end

  def max_tokens_per_hour
    self.class.max_tokens_per_hour
  end

private

  def throttle_check
    fail(MaxNumberOfTokensError) if tokens_in_the_last_hour.count >= max_tokens_per_hour
  end

  def deactivate_tokens
    Token.where(spent: false, user_email: user_email).each do |token|
      token.spend! if token != self
    end
  end

  def generate_value
    self.value ||= SecureRandom.uuid
  end

  def tokens_in_the_last_hour
    Token.where(user_email: user_email, created_at: 1.hour.ago..Time.now)
  end
end
