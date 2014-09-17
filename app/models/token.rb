class Token < ActiveRecord::Base
  after_initialize :generate_value

  validate :valid_email_address

  def to_param
    value
  end

  def valid_email_address
    if !EmailAddress.new(user_email).valid_address?
      errors.add(:user_email, I18n.t('errors.tokens.invalid_address'))
    elsif !EmailAddress.new(user_email).valid_domain?
      errors.add(:user_email, I18n.t('errors.tokens.invalid_domain'))
    end
  end

  def self.for_person(person)
    Token.create!(user_email: person.email)
  end

private

  def generate_value
    self.value ||= SecureRandom.uuid
  end
end
