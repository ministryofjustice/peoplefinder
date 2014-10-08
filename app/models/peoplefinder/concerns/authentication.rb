require 'peoplefinder'

module Peoplefinder::Concerns::Authentication
  extend ActiveSupport::Concern

  included do
    def self.from_auth_hash(auth_hash)
      email = EmailAddress.new(auth_hash['info']['email'])
      return unless email.valid_domain?

      person = Person.from_email(email)
      if person.new_record?
        person.given_name = auth_hash['info']['first_name']
        person.surname = auth_hash['info']['last_name']
        person.save!
      end
      person
    end

    def self.from_token(token)
      email = EmailAddress.new(token.user_email)

      person = Person.from_email(email)
      if person.new_record?
        person.given_name = email.inferred_first_name
        person.surname = email.inferred_last_name
        person.save!
      end
      person
    end

    def self.from_email(email)
      Person.where(email: email.to_s).first_or_initialize
    end
  end
end
