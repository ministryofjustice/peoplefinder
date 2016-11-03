module SessionPersonCreator
  extend ActiveSupport::Concern

  included do
    def person_from_auth_hash(auth_hash)
      email = EmailAddress.new(auth_hash['info']['email'])
      return unless email.permitted_domain?

      find_or_create_person(email) do |person|
        person.given_name = auth_hash['info']['first_name']
        person.surname = auth_hash['info']['last_name']
      end
    end

    def person_from_token(token)
      email = EmailAddress.new(token.user_email)

      find_or_create_person(email) do |person|
        person.given_name = email.inferred_first_name
        person.surname = email.inferred_last_name
      end
    end

    private

    def find_or_create_person(email, &_on_create)
      person = Person.
               where(email: email.to_s).first_or_initialize

      if person.new_record?
        yield(person)
        person.save!
        html_safe_notice :profile_created_from_login_html, href: edit_person_path(person)
      end

      person
    end
  end
end
