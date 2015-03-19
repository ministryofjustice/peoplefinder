require 'peoplefinder'

class Peoplefinder::ReminderMailer < ActionMailer::Base
  include Peoplefinder::FeatureHelper
  layout 'peoplefinder/email'

  def inadequate_profile(person)
    @person = person
    @edit_url = edit_person_url(@person)
    mail to: @person.email
  end

  def information_request(information_request)
    @person = information_request.recipient
    @edit_url = edit_person_url(@person)
    @message = information_request.message

    mail to: @person.email
  end

  def reported_profile(reported_profile)
    @subject = reported_profile.subject
    @notifier = reported_profile.notifier
    @reason_for_reporting = reported_profile.reason_for_reporting
    @additional_details = reported_profile.additional_details

    mail to: reported_profile.recipient_email
  end
end
