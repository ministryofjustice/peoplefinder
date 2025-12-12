module ExposeMandatoryFields
  extend ActiveSupport::Concern

  included do
    delegate :mandates_presence_of?, to: :class

    def self.mandates_presence_of?(field)
      validators_on(field).map(&:class)
        .include?(ActiveRecord::Validations::PresenceValidator)
    end
  end
end
