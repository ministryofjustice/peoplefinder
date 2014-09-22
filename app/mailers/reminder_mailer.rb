class ReminderMailer < ActionMailer::Base
  def inadequate_profile(person)
    @person = person
    @token = Token.for_person(@person)
    mail to: @person.email, subject: 'Reminder: update your profile today'
  end

  def information_request(information_request)
    @person = information_request.recipient
    @token = Token.for_person(@person)
    @message = information_request.message

    mail to: @person.email,
         subject: 'Request to update your People Finder profile'
  end
end
