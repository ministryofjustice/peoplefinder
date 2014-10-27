require 'peoplefinder'

class Peoplefinder::UserUpdateMailer < ActionMailer::Base
  include Peoplefinder::FeatureHelper

  def new_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: @person.email
  end

  def updated_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
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
    @profile_url = profile_url(person)
    mail to: old_email
  end

  def updated_address_to_email(person, by_email, _old_email)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: @person.email
  end

private

  def profile_url(person)
    if feature_enabled?('token_auth')
      token_url(
        id: Peoplefinder::Token.for_person(person).to_param,
        desired_path: person_path(person)
      )
    else
      person_url(person)
    end
  end
end
