require 'peoplefinder'

module Peoplefinder::Concerns::Completion
  extend ActiveSupport::Concern

  ADEQUATE_FIELDS = [
    :image, :location_in_building, :building, :city, :primary_phone_number
  ]

  COMPLETION_FIELDS = [
    :given_name, :surname, :email, :location_in_building, :building, :city,
    :primary_phone_number, :description, :groups, :image
  ]

  included do
    def self.inadequate_profiles
      criteria = ADEQUATE_FIELDS.map { |f| "COALESCE(#{f}, '') = ''" }.join(' OR ')
      where(criteria).order(:email)
    end

    def completion_score
      completed = COMPLETION_FIELDS.map { |f| send(f).present? }
      (100 * completed.select { |f| f }.length) / COMPLETION_FIELDS.length
    end

    def incomplete?
      completion_score < 100
    end
  end
end
