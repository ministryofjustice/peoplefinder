module ApplicationHelper

  def pluralize_with_delimiter number, text
    "#{ number_with_delimiter(number) } #{ text.pluralize(number) }"
  end

  def last_update
    current_object = @person || @group
    if current_object && current_object.updated_at.present?
      "#{ updated_at(current_object) }#{ updated_by(current_object) }."
    end
  end

  def govspeak(source)
    options = { header_offset: 2 }
    doc = Govspeak::Document.new(source, options)
    doc.to_sanitized_html.html_safe
  end

  def breadcrumbs(items)
    render partial: 'shared/breadcrumbs',
           locals: { items: items }
  end

  FLASH_NOTICE_KEYS = %w[ error notice warning ]

  def flash_messages
    messages = flash.keys.map(&:to_s) & FLASH_NOTICE_KEYS
    return if messages.empty?
    content_tag(:div, class: 'inner-block') {
      content_tag(:div, id: 'flash-messages') {
        messages.inject(ActiveSupport::SafeBuffer.new) { |html, type|
          html << flash_message(type)
        }
      }
    }
  end

  def error_text(key)
    t(key, scope: 'errors')
  end

  def info_text(key)
    t(key, scope: 'views.info_text')
  end

  def link_to_short_name_unless_current(obj)
    full_name = obj.name

    if obj.respond_to?(:short_name) && obj.short_name.present?
      link_text = obj.short_name
    else
      link_text = full_name
    end

    html_options = (full_name == link_text) ? {} : { title: full_name }

    link_to_unless_current link_text, obj, html_options
  end

  def app_title
    Rails.configuration.app_title
  end

  def page_title
    (
      [@page_title] << Rails.configuration.app_title
    ).compact.join(' - ')
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

private

  def updated_at(obj)
    "Last updated: #{l(obj.updated_at)}"
  end

  def updated_by(obj)
    unless obj.originator == Version.public_user
      " by #{ obj.originator }"
    end
  end

  def flash_message(type)
    content_tag(:div, class: "flash-message #{type}", role: 'alert') {
      flash[type]
    }
  end

  def editing_mode(building = false)
    @editing_mode = true
    content_for :editing_alert do
      if building
        render partial: 'shared/building_alert'
      else
        render partial: 'shared/editing_alert'
      end
    end
  end
end
