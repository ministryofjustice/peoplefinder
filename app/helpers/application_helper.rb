module ApplicationHelper
  FLASH_NOTICE_KEYS = %w[ error notice warning ]

  def flash_messages
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?
    content_tag(:div, class: 'inner-block') {
      content_tag(:div, id: 'flash-messages') {
        messages.map { |type| flash_message(type) }.join.html_safe
      }
    }
  end

  def financial_year(the_date = Date.today)
    the_date = the_date.last_year if the_date.month < 4
    "#{ the_date.strftime('%Y') }/#{ the_date.next_year.strftime('%y') }"
  end

  def sign_off_box(form, role)
    field = "objectives_signed_off_by_#{role}"
    person = form.object.send(role)
    form.input(
      field,
      label: sign_off_label(field, person),
      label_html: { class: 'block-label' },
      disabled: person != current_user
    )
  end

private

  def sign_off_label(field, person)
    t(field, scope: 'simple_form.labels.objectives_agreement', name: person)
  end

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}") {
      flash[type]
    }
  end
end
