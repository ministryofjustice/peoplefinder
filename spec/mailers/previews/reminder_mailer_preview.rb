class ReminderMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def never_logged_in_email
    ReminderMailer.never_logged_in recipient
  end

  def team_description_missing_email
    ReminderMailer.team_description_missing(recipient, team)
  end

  def person_profile_update_email
    ReminderMailer.person_profile_update recipient
  end

end
