class UserUpdateMailer < ActionMailer::Base
  include FeatureHelper
  layout 'email'

  def new_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: @person.email
  end

  def updated_profile_email(person, changes, by_email = nil)
    @person = person
    @changes = changes
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: person.email, cc: changes[:email]&.first
  end

  def deleted_profile_email(recipient_email, recipient_name, by_email = nil)
    @by_email = by_email
    @name = recipient_name
    mail to: recipient_email
  end

  private

  def profile_url(person)
    person_url(person)
  end
end
