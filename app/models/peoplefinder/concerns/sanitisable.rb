require 'peoplefinder'

module Peoplefinder::Concerns::Sanitisable
  extend ActiveSupport::Concern

  included do
    class_attribute :fields_to_sanitise, instance_writer: false
    self.fields_to_sanitise = []

    before_validation :sanitise!
  end

  def sanitise!
    fields_to_sanitise.each do |field_name|
      field = send(field_name)
      field.strip! if field && field.respond_to?(:strip!)
    end
  end

  module ClassMethods
    def sanitise_fields(*fields)
      self.fields_to_sanitise = fields
    end
  end
end
