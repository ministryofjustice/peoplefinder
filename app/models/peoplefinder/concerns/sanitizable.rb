require 'peoplefinder'

module Peoplefinder::Concerns::Sanitizable
  extend ActiveSupport::Concern

  included do
    class_attribute :fields_to_sanitize, instance_writer: false
    self.fields_to_sanitize = {}

    before_validation :sanitize!
  end

  def sanitize!
    fields_to_sanitize.each do |field, options|
      value = send(field)
      next unless value
      value.strip! if value.respond_to?(:strip!) && options[:strip]
      value.downcase! if value.respond_to?(:downcase) && options[:downcase]
    end
  end

  module ClassMethods
    def sanitize_fields(*fields, **options)
      fields.each do |field|
        fields_to_sanitize[field] = options
      end
    end
  end
end
