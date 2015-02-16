require 'peoplefinder'

module Peoplefinder::Concerns::Completion
  extend ActiveSupport::Concern

  included do
    def completion_score_fields
      [
        :given_name, :surname, :email, :location_in_building, :building, :city,
        :primary_phone_number, :description, :groups, :image
      ]
    end

    def self.inadequate_profiles
      fields = [:image, :location_in_building, :building, :city,
                :primary_phone_number]
      criteria = fields.map { |f| "COALESCE(#{f}, '') = ''" }.join(' OR ')

      where(criteria).order(:email)
    end

    def completion_score
      completed = completion_score_fields.map { |f| send(f).present? }
      (100 * completed.select { |f| f }.length) / completion_score_fields.length
    end

    def incomplete?
      completion_score < 100
    end
  end
end
