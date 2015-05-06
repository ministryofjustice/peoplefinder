# Why is this a Concern? It really isn't.
#
module Concerns::Completion
  extend ActiveSupport::Concern

  ADEQUATE_FIELDS = [
    :image, :location_in_building, :building, :city, :primary_phone_number
  ]

  COMPLETION_FIELDS = [
    :given_name, :surname, :email, :location_in_building, :building, :city,
    :primary_phone_number, :groups, :image
  ]

  included do
    def self.inadequate_profiles
      criteria = ADEQUATE_FIELDS.map { |f| "COALESCE(#{f}, '') = ''" }.join(' OR ')
      where(criteria).order(:email)
    end

    def self.overall_completion
      all.map(&:completion_score).inject(0.0, &:+) / count
    end

    def completion_score
      completed = COMPLETION_FIELDS.map { |f| send(f).present? }
      (100 * completed.select { |f| f }.length) / COMPLETION_FIELDS.length
    end

    def incomplete?
      completion_score < 100
    end

    def complete?
      !incomplete?
    end

    def needed_for_completion?(field)
      COMPLETION_FIELDS.include?(field) && send(field).blank?
    end
  end
end
