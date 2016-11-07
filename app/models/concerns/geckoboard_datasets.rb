
module Concerns::GeckoboardDatasets
  extend ActiveSupport::Concern

  class_methods do

    # count of profiles created in last 6 months grouped by day created
    def total_profiles_by_day
      unscoped.
        group("DATE_TRUNC('day', created_at)").
        where(created_at: 6.months.ago..Date.current).
        count
    end

    # count of profiles with photos grouped by day photo was added/created
    # NOTE does not include legacy photos
    def photo_profiles_by_day_added
      unscoped.
        where.not(profile_photo: nil).
        where.not(profile_photos: { image: nil }).
        joins(:profile_photo).
        group("DATE_TRUNC('day',profile_photos.created_at)").
        count
    end

    def legacy_photo_profiles_by_day_added
      unscoped.
        where.not(image: nil).
        joins(:versions).
        where('versions.object_changes ILIKE ?', '%image:%').
        group("DATE_TRUNC('day',versions.created_at)").
        count
    end

    def total_profiles
      unscoped.count
    end

    def total_photo_profiles
      unscoped.
        where('profile_photo_id IS NOT NULL OR length(image) > 0').
        count
    end

    def total_additional_info_profiles
      unscoped.
        where('length(description) > 0 OR length(current_project) > 0').
        count
    end

    def non_members
      unscoped.
        joins('LEFT JOIN memberships ON memberships.person_id = people.id').
        where('memberships.id IS NULL')
    end
  end

end
