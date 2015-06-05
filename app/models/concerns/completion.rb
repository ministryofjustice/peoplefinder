# Why is this a Concern? It really isn't.
#
module Concerns::Completion
  extend ActiveSupport::Concern

  ADEQUATE_FIELDS = %i[
    building
    city
    location_in_building
    primary_phone_number
    profile_photo_id
  ]

  COMPLETION_FIELDS = ADEQUATE_FIELDS + %i[
    email
    given_name
    groups
    surname
  ]

  included do
    def self.inadequate_profiles
      criteria = ADEQUATE_FIELDS.map { |f|
        "coalesce(cast(#{f} AS text), '') = ''"
      }.join(' OR ')
      where(criteria).order(:email)
    end

    def self.overall_completion
      all.map(&:completion_score).inject(0.0, &:+) / count
    end

    BUCKETS = [0...20, 20...50, 50...80, 80..100]

    def self.bucketed_completion
      results = Hash[BUCKETS.map { |r| [r, 0] }]
      all.map(&:completion_score).each do |score|
        bucket = BUCKETS.find { |b| b.include?(score) }
        results[bucket] += 1
      end
      results
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
