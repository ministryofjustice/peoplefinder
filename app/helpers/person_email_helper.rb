module PersonEmailHelper
  def email_update_info_message(person)
    if person.secondary_email.present?
      t("original_email_info_html", scope: %i[controllers person_email], email: Person.find(person.id).email)
    else
      t("info_message_html", scope: %i[controllers person_email])
    end
  end
end
