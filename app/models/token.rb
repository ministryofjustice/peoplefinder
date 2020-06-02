# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  value      :text
#  user_email :text
#  created_at :datetime
#  updated_at :datetime
#  spent      :boolean          default(FALSE)
#
require 'secure'

class Token < ApplicationRecord
  class TTLRaceCondition < StandardError; end

  include Concerns::Sanitizable

  sanitize_fields :user_email, strip: true, downcase: true
  after_create :deactivate_tokens, :remove_expired_tokens

  after_initialize :generate_value

  validate :valid_email_address
  validate :within_throttle_limit, on: :create

  DEFAULT_TTL = 86_400
  DEFAULT_MAX_TOKENS_PER_HOUR = 8
  DEFAULT_EXTRA_EXPIRY_PERIOD = 10.minutes

  scope :spent,            -> { where(spent: true) }
  scope :unspent,          -> { where(spent: false) }
  scope :unexpired,        -> { where('created_at > ?', ttl.seconds.ago) }
  scope :expired,          -> { where('created_at < ?', ttl.seconds.ago) }
  scope :active,           -> { unspent.unexpired }
  scope :in_the_last_hour, -> { where(created_at: 1.hour.ago..Time.zone.now) }

  def self.find_unspent_by_user_email user_email
    unspent.find_by_user_email(user_email)
  end

  def self.find_securely token_value
    find_each do |token|
      return token if Secure.compare(token.value, token_value)
    end
  end

  def to_param
    value
  end

  def valid_email_address
    if !EmailAddress.new(user_email).valid_format?
      errors.add(:user_email, :invalid_address)
    elsif !EmailAddress.new(user_email).permitted_domain?
      errors.add(:user_email, :invalid_domain)
    end
  end

  def self.for_person(person)
    Token.create!(user_email: person.email)
  end

  def active?
    return scanned_token_active? if Rails.host.dev? || Rails.host.staging?
    token_active?
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
    Integer(Rails.configuration.try(:max_tokens_per_hour) || DEFAULT_MAX_TOKENS_PER_HOUR)
  end

  def max_tokens_per_hour
    self.class.max_tokens_per_hour
  end

  def within_throttle_limit
    raise TTLRaceCondition, 'throttling will not work with TTLs of 1 hour or less' if ttl <= 60

    if tokens_in_the_last_hour >= max_tokens_per_hour
      errors.add(:user_email, :token_throttle_limit, limit: max_tokens_per_hour)
    end
  end

  def within_validity_period?
    spent? && created_at > DEFAULT_EXTRA_EXPIRY_PERIOD.ago
  end

  private

  # NOTE: dev and staging mails are scanned (possibly because they are not gov.uk)
  # and this will spend them so
  def scanned_token_active?
    token_active? || within_validity_period?
  end

  def token_active?
    (created_at > ttl.seconds.ago) && !spent?
  end

  def remove_expired_tokens
    self.class.expired.destroy_all
  end
  handle_asynchronously :remove_expired_tokens, queue: :high_priority

  def deactivate_tokens
    self.class.unspent.where('user_email = ? AND id != ?', user_email, id).update_all(spent: true)
  end

  def generate_value
    self.value ||= SecureRandom.uuid
  end

  def tokens_in_the_last_hour
    self.class.in_the_last_hour.where(user_email: user_email).count
  end
end
