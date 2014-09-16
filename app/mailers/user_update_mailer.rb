class UserUpdateMailer < ActionMailer::Base
  def new_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    mail to: @person.email
  end

  def updated_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
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
    mail to: old_email
  end

  def updated_address_to_email(person, by_email, _old_email)
    @person = person
    @by_email = by_email
    mail to: @person.email
  end
end
