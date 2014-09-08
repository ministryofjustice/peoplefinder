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
      @subject ? :direct_reports : :your_feedback

    when 'users'
      :direct_reports

    when 'feedback_requests', 'invitations', 'replies', 'submissions', 'pages'
      :feedback_requests

    end
  end

  def your_feedback_tab?
    active_tab == :your_feedback
  end

  def direct_reports_tab?
    active_tab == :direct_reports
  end

  def feedback_requests_tab?
    active_tab == :feedback_requests
  end

private

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}") {
      flash[type]
    }
  end
end
