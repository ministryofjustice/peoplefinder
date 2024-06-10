module SessionPersonCreator
  extend ActiveSupport::Concern

  included do
    def person_from_oauth(auth_hash)
      email = EmailAddress.new(auth_hash["info"]["email"])
      return unless email.permitted_domain?

      find_or_create_person(email) do |new_person|
        new_person.given_name = auth_hash["info"]["first_name"]
        new_person.surname = auth_hash["info"]["last_name"]
      end
    end

    def person_from_token(token)
      email = EmailAddress.new(token.user_email)
      find_or_create_person(email) do |new_person|
        new_person.given_name = email.inferred_first_name
        new_person.surname = email.inferred_last_name
      end
    end

    def render_or_redirect_login(person)
      if person&.new_record?
        confirm_or_create person
      elsif person
        login_person(person)
      else
        render :failed
      end
    end

  private

    def find_or_create_person(email, &_on_create)
      if ExternalUser.exists?(email: email.to_s)
        person = ExternalUser.find_by(email: email.to_s)
      else
        person = Person.where(email: email.to_s).first_or_initialize
        yield(person) if person.new_record?
      end
      person
    end

    def confirm_or_create(person)
      @person = person
      @person.skip_must_have_team = true
      if @person.valid?
        if namesakes?
          warning :person_confirm
          render "sessions/person_confirm"
        else
          create_person_and_login @person
        end
      else
        render :failed
      end
    end

    def create_person_and_login(person)
      person_creator = PersonCreator.new(person, current_user, StateManagerCookie.new(cookies))
      person_creator.create!
      warning :complete_profile
      session[:desired_path] = edit_person_path(@person, page_title: "Create profile")
      login_person(@person)
    end

    def namesakes?
      return false if params["commit"] == "Continue, it is not one of these"

      @people = Person.namesakes(@person)
      @people.present?
    end
  end
end
