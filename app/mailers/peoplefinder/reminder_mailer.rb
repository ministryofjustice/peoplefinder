require 'peoplefinder'

class Peoplefinder::ReminderMailer < ActionMailer::Base
  include Peoplefinder::FeatureHelper

  def inadequate_profile(person)
    @person = person
    @edit_url = possibly_tokenized_edit_person_url(person)
    mail to: @person.email
  end

  def information_request(information_request)
    @person = information_request.recipient
    @edit_url = possibly_tokenized_edit_person_url(@person)
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

private

  def tokenized_edit_person_url(person)
    token = Peoplefinder::Token.for_person(person)
    token_url(token, desired_path: edit_person_path(person))
  end

  def possibly_tokenized_edit_person_url(person)
    if feature_enabled?('token_auth')
      tokenized_edit_person_url(person)
    else
      edit_person_url(person)
    end
  end
end
