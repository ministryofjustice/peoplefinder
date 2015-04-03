class ReminderMailer < ActionMailer::Base
  include FeatureHelper
  layout 'email'

  def inadequate_profile(person)
    @person = person
    @edit_url = edit_person_url(@person)
    mail to: @person.email
  end
end
