module Concerns::Sanitizable
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
      sanitize_value! value, options
    end
  end

  private

  def sanitize_value! value, options
    value.strip! if strip?(value, options)
    value.downcase! if downcase?(value, options)
    value.gsub!(/\d/, '') if remove_digits?(value, options)
  end

  def strip? value, options
    value.respond_to?(:strip!) && options[:strip]
  end

  def downcase? value, options
    value.respond_to?(:downcase!) && options[:downcase]
  end

  def remove_digits? value, options
    value.respond_to?(:gsub!) && options[:remove_digits]
  end

  module ClassMethods
    def sanitize_fields(*fields, **options)
      fields.each do |field|
        fields_to_sanitize[field] = options
      end
    end
  end
end
