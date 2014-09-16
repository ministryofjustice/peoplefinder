class ReminderMailer < ActionMailer::Base
  def inadequate_profile(person)
    @person = person
    mail to: @person.email, subject: 'Update your Peoplefinder profile'
  end
end
