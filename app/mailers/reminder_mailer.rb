class ReminderMailer < ActionMailer::Base
  include FeatureHelper
  layout 'email'

  def never_logged_in(person)
    @person = person
    token = Token.for_person(person)
    @token_url = token_url(token)
    mail to: @person.email_address_with_name
  end

  def team_description_missing(person, group)
    @group = group
    @person = person
    mail to: @person.email_address_with_name
  end
end
