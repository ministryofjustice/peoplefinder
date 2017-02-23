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

  def breadcrumbs(items, show_links: true)
    starts_with_home = items.first == Home.instance
    starts_with_root_team = items.first == Group.department
    render partial: 'shared/breadcrumbs',
           locals: { items: items, show_links: show_links,
             starts_with_home: starts_with_home,
            starts_with_root_team: starts_with_root_team }
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

  def link_to_breadcrumb_name_unless_current(obj, index, starts_with_home: nil, starts_with_root_team: nil)
    index = adjust_breadcrumb_index(index, starts_with_home, starts_with_root_team)
    link_text = if index < 3 && obj.respond_to?(:short_name) && obj.short_name.present?
                  obj.short_name
                else
                  obj.name
                end

    html_options = (obj.name == link_text) ? {} : { title: obj.name }
    link_to_unless_current link_text, obj, html_options
  end

  def adjust_breadcrumb_index index, starts_with_home, starts_with_root_team
    if starts_with_home
      index - 1
    elsif starts_with_root_team
      index
    else
      index + 1
    end
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
