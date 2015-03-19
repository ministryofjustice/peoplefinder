require 'peoplefinder'

class Peoplefinder::Token < ActiveRecord::Base
  include Peoplefinder::Concerns::Sanitizable
  sanitize_fields :user_email, strip: true, downcase: true

  self.table_name = 'tokens'

  after_initialize :generate_value

  validate :valid_email_address

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

private

  def generate_value
    self.value ||= SecureRandom.uuid
  end
end
