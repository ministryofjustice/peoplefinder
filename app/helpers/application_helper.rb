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

  def active_tab
    case controller_name
    when 'reviews'
      scoped_by_subject? ? :your_direct_reports : :your_feedback
    when 'users'
      :your_direct_reports
    when 'feedback_requests', 'invitations', 'replies', 'submissions', 'pages'
      :feedback_requests
    end
  end

  def render_tab(tab_id, link)
    render(
      partial: 'shared/tab',
      locals: {
        text: t(tab_id, scope: 'tab_navigation'),
        link: link,
        selected: active_tab == tab_id
      }
    )
  end

  def govspeak(source)
    options = { header_offset: 2 }
    doc = Govspeak::Document.new(source, options)
    doc.to_sanitized_html.html_safe
  end

  def t_boolean(prefix, value)
    t((value ? 'true' : 'false'), scope: prefix)
  end

  def date(d)
    d.to_date.to_formatted_s(:default)
  end

private

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}") {
      flash[type]
    }
  end
end
