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

  def reported_profile(reported_profile)
    @subject = reported_profile.subject
    @notifier = reported_profile.notifier
    @reason_for_reporting = reported_profile.reason_for_reporting
    @additional_details = reported_profile.additional_details

    mail to: reported_profile.recipient_email,
         subject: 'A People Finder profile has been reported'
  end
end
