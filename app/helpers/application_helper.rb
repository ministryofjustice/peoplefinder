module ApplicationHelper
  def last_update
    if current_object = @person || @group
      unless current_object.updated_at.blank?
        "Last updated: #{ current_object.updated_at.strftime('%d %b %Y %H:%M') }."
      end
    end
  end

  def govspeak(source)
    options = { header_offset: 2 }
    doc = Govspeak::Document.new(source, options)
    doc.to_html.html_safe
  end

  def breadcrumbs(items)
    render partial: "shared/breadcrumbs", locals: { items: items }
  end

  FLASH_NOTICE_KEYS = %w[ error notice warning ]

  def flash_messages
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?
    content_tag(:div, class: 'inner-block') {
      content_tag(:div, id: 'flash-messages') {
        messages.map { |type|
          content_tag(:div, class: "flash-message #{type.to_s}") {
            flash[type]
          }
        }.join.html_safe
      }
    }
  end
end
