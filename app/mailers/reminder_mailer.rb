class ReminderMailer < ActionMailer::Base
  include FeatureHelper
  layout 'email'
  add_template_helper PeopleHelper

  def never_logged_in(person)
    @person = person
    @token_url = token_url_for(person)
    mail to: @person.email_address_with_name
  end

  def team_description_missing(person, group)
    @group = group
    @person = person
    mail to: @person.email_address_with_name
  end

  def person_profile_update(person)
    @person = person
    @token_url = token_url_for(person)
    mail to: @person.email_address_with_name
  end

  private

  def token_url_for person
    token = Token.for_person(person)
    token_url(token)
  end
end
