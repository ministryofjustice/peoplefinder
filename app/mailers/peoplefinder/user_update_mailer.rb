require 'peoplefinder'

class Peoplefinder::UserUpdateMailer < ActionMailer::Base
  def new_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    set_token_params
    mail to: @person.email
  end

  def updated_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    set_token_params
    mail to: @person.email
  end

  def deleted_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    mail to: @person.email
  end

  def updated_address_from_email(person, by_email, old_email)
    @person = person
    @by_email = by_email
    set_token_params
    mail to: old_email
  end

  def updated_address_to_email(person, by_email, _old_email)
    @person = person
    @by_email = by_email
    set_token_params
    mail to: @person.email
  end

private

  def set_token_params
    @token_params = {
      id: Peoplefinder::Token.for_person(@person).to_param,
      desired_path: "/people/#{ @person.to_param }"
    }
  end
end
