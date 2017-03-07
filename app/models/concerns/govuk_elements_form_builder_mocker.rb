module Concerns::GovukElementsFormBuilderMocker
  extend ActiveSupport::Concern

  included do
    attr_accessor :name
    attr_reader :errors

    def validate!
      # validations to implement
      # e.g. errors.add(:name, :blank, message: "cannot be nil") if name.nil?
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.human_attribute_name(attr, options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end
  end

end