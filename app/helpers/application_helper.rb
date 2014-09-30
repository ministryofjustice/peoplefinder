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

  def app_name
    'SCS 360&deg; Appraisals'.html_safe
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
    doc.to_html.html_safe
  end

  def back_link
    link_to t('common.go_back'), :back
  end

private

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}") {
      flash[type]
    }
  end
end
