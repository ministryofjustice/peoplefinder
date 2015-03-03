require 'peoplefinder'

class Peoplefinder::ReminderMailer < ActionMailer::Base
  include Peoplefinder::FeatureHelper
  layout 'peoplefinder/email'

  def inadequate_profile(person)
    @person = person
    @edit_url = edit_person_url(@person)
    mail to: @person.email
  end
end
