
module Concerns::GeckoboardDatasets
  extend ActiveSupport::Concern

  class_methods do

    def total_profiles_by_day
      unscoped.
        group("DATE_TRUNC('day', created_at)").
        count
    end

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

    def profile_events
      pgresults = ActiveRecord::Base.connection.execute profile_events_raw_sql
      pgresults
    end

    private

    def profile_events_raw_sql
      <<-SQL
        SELECT count(*), DATE_TRUNC('day',v.created_at) AS event_date, v.event AS event
        FROM versions v
        WHERE item_type = 'Person'
        AND v.event IN ('create','update','destroy')
        GROUP BY event_date, event
      SQL
    end

  end

end
