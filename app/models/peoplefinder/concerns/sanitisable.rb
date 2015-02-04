require 'peoplefinder'

module Peoplefinder::Concerns::Sanitisable
  extend ActiveSupport::Concern

  included do
    class_variable_set(:@@fields_to_sanitise, [])
    before_validation :sanitise!
  end

  def sanitise!
    self.class.class_variable_get(:@@fields_to_sanitise).each do |field_name|
      field = send(field_name)
      field.strip! if field && field.respond_to?(:strip!)
    end
  end

  module ClassMethods
    def sanitise_fields(*fields)
      class_variable_set(:@@fields_to_sanitise, fields)
    end
  end
end
