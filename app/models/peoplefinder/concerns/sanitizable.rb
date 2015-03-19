require 'peoplefinder'

module Peoplefinder::Concerns::Sanitizable
  extend ActiveSupport::Concern

  included do
    class_attribute :fields_to_sanitize, instance_writer: false
    self.fields_to_sanitize = []

    before_validation :sanitize!
  end

  def sanitize!
    fields_to_sanitize.each do |field_name|
      field = send(field_name)
      field.strip! if field && field.respond_to?(:strip!)
    end
  end

  module ClassMethods
    def sanitize_fields(*fields)
      self.fields_to_sanitize = fields
    end
  end
end
