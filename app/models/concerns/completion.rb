# Why is this a Concern? It really isn't.
#
module Concerns::Completion
  extend ActiveSupport::Concern

  ADEQUATE_FIELDS = %i(
    building
    city
    location_in_building
    primary_phone_number
  )

  COMPLETION_FIELDS = ADEQUATE_FIELDS + %i(
    profile_photo_present?
    email
    given_name
    groups
    surname
  )

  included do
    def self.inadequate_profiles
      criteria = ADEQUATE_FIELDS.map do |f|
        "coalesce(cast(#{f} AS text), '') = ''"
      end.join(' OR ')
      profile_missing = "( coalesce(cast(profile_photo_id AS text), '') = '' AND " \
        "coalesce(cast(image AS text), '') = '' )"
      criteria += " OR #{profile_missing}"
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
      (100 * completed.count { |f| f }) / COMPLETION_FIELDS.length
    end

    def profile_photo_present?
      profile_photo_id || attributes['image']
    end

    def incomplete?
      completion_score < 100
    end

    def complete?
      !incomplete?
    end

    def needed_for_completion?(field)
      if field == :profile_photo_id
        !profile_photo_present?
      else
        COMPLETION_FIELDS.include?(field) && send(field).blank?
      end
    end
  end
end
