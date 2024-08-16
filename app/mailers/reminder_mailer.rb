class ReminderMailer < ApplicationMailer
  include PeopleHelper

  def never_logged_in(person)
    set_template("afea2e90-d721-4cbe-be97-a89dd6973af6")

    set_personalisation(
      name: person.given_name,
      token_url: token_url_for(person),
    )

    mail(to: person.email_address_with_name)
  end

  def team_description_missing(person, group)
    set_template("eecbbb2a-b8c9-4783-b70f-c48b2bacaed8")

    set_personalisation(
      name: person.given_name,
      edit_group_url: edit_group_url(group),
    )

    mail(to: person.email_address_with_name)
  end

  def person_profile_update(person)
    set_template("ad85435b-3c8f-4092-865a-4320ff5745f1")

    set_personalisation(
      given_name: person.given_name,
      person_name: person.name,
      days_worked: days_worked(person),
      teams_and_roles: teams_and_roles(person),
      location: person.location.presence || "-",
      secondary_email: person.secondary_email || "-",
      primary_phone_number: person.primary_phone_number.presence || "-",
      current_projects: person.current_project.presence || "-",
      description: person.description || "-",
      token_url: token_url_for(person),
    )

    mail(to: person.email_address_with_name)
  end

private

  def token_url_for(person)
    token = Token.for_person(person)
    token_url(token)
  end
end
