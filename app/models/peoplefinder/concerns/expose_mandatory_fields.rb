module Peoplefinder::Concerns::ExposeMandatoryFields
  extend ActiveSupport::Concern

  included do
    def self.mandates_presence_of?(field)
      validators_on(field).map(&:class).
        include?(ActiveRecord::Validations::PresenceValidator)
    end

    def mandates_presence_of?(field)
      self.class.mandates_presence_of?(field)
    end
  end
end
