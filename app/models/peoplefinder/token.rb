require 'peoplefinder'

class Peoplefinder::Token < ActiveRecord::Base
  include Peoplefinder::Concerns::Sanitizable
  sanitize_fields :user_email, strip: true, downcase: true
  after_create :deactivate_tokens

  self.table_name = 'tokens'

  after_initialize :generate_value

  validate :valid_email_address

  DEFAULT_TTL_HOURS = 3

  def to_param
    value
  end

  def valid_email_address
    if !Peoplefinder::EmailAddress.new(user_email).valid_format?
      errors.add(:user_email, :invalid_address)
    elsif !Peoplefinder::EmailAddress.new(user_email).valid_domain?
      errors.add(:user_email, :invalid_domain)
    end
  end

  def self.for_person(person)
    Peoplefinder::Token.create!(user_email: person.email)
  end

  def active?
    (created_at > ttl_hours.hours.ago) && !spent?
  end

  def self.ttl_hours
    Rails.configuration.try(:token_ttl) || DEFAULT_TTL_HOURS
  end

  def ttl_hours
    self.class.ttl_hours
  end

  def spend!
    update_attributes!(spent: true)
  end

private

  def deactivate_tokens
    Peoplefinder::Token.where(spent: false, user_email: user_email).each do |token|
      token.spend! if token != self
    end
  end

  def generate_value
    self.value ||= SecureRandom.uuid
  end
end
