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

private

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}") {
      flash[type]
    }
  end
end
