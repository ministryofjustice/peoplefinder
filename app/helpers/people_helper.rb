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
      (person.phone if person.phone.present?),
      ("Mob: #{ person.mobile }" if person.mobile.present?)
    ].compact.join('<br/>').html_safe
  end

  def remove_membership_link(membership)
    ret = ''
    if group = membership.group
      ret = link_to "remove", membership_path(membership, referer: edit_person_path(@person)),
            method: :delete,
            data: { :confirm => 'Are you sure you want to remove this group?' }
    end
    "Group #{ ret }".html_safe
  end
end
