class ReminderMailer < ActionMailer::Base
  def inadequate_profile(person)
    @person = person
    @token = Token.for_person(@person)
    mail to: @person.email, subject: 'Reminder: update your profile today'
  end
end
