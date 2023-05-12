class UserUpdateMailer < ApplicationMailer
  def new_profile_email(person, by_email = nil)
    set_template('9bc86cfd-588e-4318-8653-d1544ceeab8b')

    set_personalisation(
      name: person.given_name,
      profile_url: person_url(person)
    )

    mail(to: person.email)
  end

  def updated_profile_email(person, serialized_changes, by_email = nil)
    return if person.nil?

    changes = ProfileChangesPresenter.deserialize(serialized_changes)

    set_template('df798a71-5ab9-437b-88e2-57d3f2011585')

    set_personalisation(
      name: person.given_name,
      changed_by: by_email.presence || "Someone",
      changes: changes.all_messages.join("; "),
      profile_url: person_url(person)
    )

    mail(to: [person.email, changes.raw['email']&.first])
  end

  def deleted_profile_email(recipient_email, recipient_name, by_email = nil)
    set_template('e8375687-c1c9-4eec-a105-b9b8bc64785d')

    deleted_by = ""
    contact = Rails.configuration.support_email

    if by_email.present?
      deleted_by = "by #{by_email}"
      contact = "#{by_email} directly"
    end

    set_personalisation(
      name: recipient_name,
      deleted_by: deleted_by,
      contact: contact
    )

    mail(to: recipient_email)
  end
end
