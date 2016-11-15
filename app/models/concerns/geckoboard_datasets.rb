
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

    # TODO: incorporate into photo profiles by daya added
    # def legacy_photo_profiles_by_day_added
    #   unscoped.
    #     where.not(image: nil).
    #     joins(:versions).
    #     where('versions.object_changes ILIKE ?', '%image:%').
    #     group("DATE_TRUNC('day',versions.created_at)").
    #     count
    # end

    def photo_profiles
      unscope(:order).
        where('profile_photo_id IS NOT NULL OR length(image) > 0')
    end

    def additional_info_profiles
      unscope(:order).
        where(additional_info_exists)
    end

    def not_in_team
      unscoped.
        joins('LEFT JOIN memberships ON memberships.person_id = people.id').
        where('memberships.id IS NULL')
    end

    def not_in_subteam
      Group.find_by(ancestry_depth: 0).people_outside_subteams
    end

    def profile_events
      pgresults = ActiveRecord::Base.connection.execute profile_events_raw_sql
      pgresults
    end

    def not_in_tip_team
      non_branch_tip_teams = Group.all.select(&:has_children?).map(&:id)
      unscoped.
        joins(:memberships).
        where(memberships: { group_id: non_branch_tip_teams })
    end

    def completion_per_top_level_teams
      top_level_teams = Group.where(ancestry_depth: [1])
      results = []
      top_level_teams.each do |group|
        set = {}
        set[:team] = (group.acronym || group.name)
        set[:total] = all_in_subtree(group).count
        set[:with_photos] = all_in_subtree(group).photo_profiles.count
        set[:with_additional_info] = all_in_subtree(group).additional_info_profiles.count
        results << set
      end
      results
    end

    private

    def profile_events_raw_sql
      <<~SQL
        SELECT count(*), DATE_TRUNC('day',v.created_at) AS event_date, v.event AS event
        FROM versions v
        WHERE item_type = 'Person'
        AND v.event IN ('create','update','destroy')
        GROUP BY event_date, event
        ORDER BY event_date ASC
      SQL
    end

    def additional_info_exists
      <<~SQL
        #{length_excluding_whitespace(:description)} > 0
        OR #{length_excluding_whitespace(:current_project)} > 0
      SQL
    end

    def length_excluding_whitespace column_name
      "length(regexp_replace(#{column_name},'[\s\t\n]+','','g'))"
    end

  end

end
