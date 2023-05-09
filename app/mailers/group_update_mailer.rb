class GroupUpdateMailer < GovukNotifyRails::Mailer
  def inform_subscriber(recipient, group, instigator)
    set_template('fabc29b0-084d-481c-95eb-09eebe4fcd29')

    set_personalisation(
      person_name: recipient.given_name,
      group: group.to_s,
      instigator_email: instigator.email,
      group_url: group_url(group),
    )

    mail(to: recipient.email)
  end
end
