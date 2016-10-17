class ReminderMailerPreview < ActionMailer::Preview

  def never_logged_in_email
    ReminderMailer.never_logged_in recipient
  end

  def team_description_missing_email
    ReminderMailer.team_description_missing(recipient, team)
  end

  def person_profile_update_email
    ReminderMailer.person_profile_update recipient
  end

  private

  def team
    @team ||= Group.find_or_create_by(name: 'Testimus\'s Team', description: nil)
  end

  def recipient
    @recipient ||= Person.find_or_create_by(given_name: 'Testimus', surname: 'Recipientus', email: 'testimus.recipientus@fake-moj.justice.gov.uk')
  end

end
