module Peoplefinder
  module ApplicationHelper
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
      render partial: 'peoplefinder/shared/breadcrumbs',
             locals: { items: items }
    end

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

    def info_text(key)
      t(key, scope: %w[peoplefinder views info_text].join('.')).html_safe
    end

    def page_title
      (
        [@page_title] << Rails.configuration.app_title
      ).compact.join(' - ')
    end

  private

    def updated_at(obj)
      "Last updated: #{l(obj.updated_at)}"
    end

    def updated_by(obj)
      unless obj.originator == Peoplefinder::Version.public_user
        " by #{ obj.originator }"
      end
    end

    def flash_message(type)
      content_tag(:div, class: "flash-message #{type}", role: 'alert') {
        flash[type]
      }
    end

    def editing_mode
      @editing_mode = true
      content_for :editing_alert do
        render partial: 'peoplefinder/shared/editing_alert'
      end
    end
  end
end
