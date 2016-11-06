
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
  end

end
