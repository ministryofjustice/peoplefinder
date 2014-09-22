module PeopleHelper
  def day_name(symbol)
    I18n.t(symbol, scope: [:people, :day_names])
  end

  def day_symbol(symbol)
    I18n.t(symbol, scope: [:people, :day_symbols])
  end

  def contact_details(person)
    [
      (mail_to(person.email) if person.email?),
      (person.primary_phone_number if person.primary_phone_number?),
      (person.secondary_phone_number if person.secondary_phone_number?)
    ].compact.join('<br/>').html_safe
  end
end
