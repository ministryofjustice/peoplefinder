module ApplicationHelper

  def pluralize_with_delimiter number, text
    "#{number_with_delimiter(number)} #{text.pluralize(number)}"
  end

  def last_update
    current_object = @person || @group
    if current_object && @last_updated_at.present?
      "#{updated_at(@last_updated_at)}#{updated_by(current_object)}."
    end
  end

  def govspeak(source)
    options = { header_offset: 2 }
    doc = Govspeak::Document.new(source, options)
    doc.to_sanitized_html.html_safe
  end

  FLASH_NOTICE_KEYS = %w(error notice warning).freeze

  def flash_messages
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?
    content_tag(:div, class: 'inner-block') do
      content_tag(:div, id: 'flash-messages') do
        messages.inject(ActiveSupport::SafeBuffer.new) do |html, type|
          html << flash_message(type)
        end
      end
    end
  end

  def error_text(key)
    t(key, scope: 'errors')
  end

  def info_text(key)
    t(key, scope: 'views.info_text')
  end

  def app_title
    Rails.configuration.app_title
  end

  def page_title
    (
      [@page_title] << Rails.configuration.app_title
    ).compact.join(' - ')
  end

  def render_search_box?
    logged_in? && !@login_screen && !@editing_mode && !@admin_management
  end

  def call_to(telno)
    return nil unless telno
    digits = telno.gsub(/[^0-9+#*,]+/, '')
    content_tag(:a, href: "tel:#{digits}") { telno }
  end

  def role_translate(subject, key, options = {})
    if subject == current_user
      subkey = 'mine'
      user = subject
    else
      subkey = 'other'
      user = current_user
    end
    I18n.t([key, subkey].join('.'), options.merge(name: user))
  end

  def bold_tag term, options = {}
    classes = options[:class] || ''
    options[:class] = classes.split.push('bold-term')
    content_tag(:span, options) { |_tag| term }
  end

  private

  def updated_at(datetime)
    "Last updated: #{l(datetime)}"
  end

  def updated_by(obj)
    " by #{obj.paper_trail_originator}" unless obj.paper_trail_originator == Version.public_user
  end

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}", role: 'alert') do
      flash[type]
    end
  end
end
