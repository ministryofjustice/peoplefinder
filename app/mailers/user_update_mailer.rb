class UserUpdateMailer < ActionMailer::Base
  default from: "peoplefinder@digital.justice.gov.uk"

  def new_profile_email(person, by_email=nil)
    @person = person
    @by_email = by_email
    mail(to: @person.email, subject: 'A new profile on MOJ People Finder has been created for you')
  end

  def updated_profile_email(person, by_email=nil)
    @person = person
    @by_email = by_email
    mail(to: @person.email, subject: 'Your profile on MOJ People Finder has been edited')
  end

  def deleted_profile_email(person, by_email=nil)
    @person = person
    @by_email = by_email
    mail(to: @person.email, subject: 'Your profile on MOJ People Finder has been deleted')
  end

  def updated_address_from_email(person, by_email, old_email)
    @person = person
    @by_email = by_email
    mail(to: old_email, subject: 'This email address has been removed from a profile on MOJ People Finder')
  end

  def updated_address_to_email(person, by_email, old_email)
    @person = person
    @by_email = by_email
    mail(to: @person.email, subject: 'This email address has been added to a profile on MOJ People Finder')
  end
end
