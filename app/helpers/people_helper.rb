module PeopleHelper
  def day_name(symbol)
    I18n.t(symbol, scope: [:people, :day_names])
  end

  def day_symbol(symbol)
    I18n.t(symbol, scope: [:people, :day_symbols])
  end

  def contact_details(person)
    [
        (mail_to(person.email) if person.email.present?),
        (person.primary_phone_number if person.primary_phone_number.present?),
        (person.secondary_phone_number if person.secondary_phone_number.present?)
    ].compact.join('<br/>').html_safe
  end

  def nag_to_complete_your_profile?(person)
    current_user.email == person.email && person.incomplete?
  end
end