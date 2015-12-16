module FindCreatePerson
  class << self
    def from_auth_hash(auth_hash)
      email = EmailAddress.new(auth_hash['info']['email'])
      return unless email.permitted_domain?

      find_or_create(email) do |person|
        person.given_name = auth_hash['info']['first_name']
        person.surname = auth_hash['info']['last_name']
      end
    end

    def from_token(token)
      email = EmailAddress.new(token.user_email)

      find_or_create(email) do |person|
        person.given_name = email.inferred_first_name
        person.surname = email.inferred_last_name
      end
    end

  private

    def find_or_create(email, &on_create)
      person = Person.
          where(email: email.to_s).first_or_initialize

      if person.new_record?
        on_create.call(person)
        person.save!
      end

      person
    end
  end
end
