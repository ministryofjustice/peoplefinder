# Queries must respond quickly so aggregation
# needs to be done on the DB for efficiency
#
module Concerns::Completion
  extend ActiveSupport::Concern

  ADEQUATE_FIELDS = %i(
    building
    city
    location_in_building
    primary_phone_number
  ).freeze

  COMPLETION_FIELDS = ADEQUATE_FIELDS + %i(
    profile_photo_present?
    email
    given_name
    surname
    groups
  )

  included do
    def completion_score
      self.class.average_completion_score(id)
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

  class_methods do
    def inadequate_profiles
      where(inadequate_profiles_sql).
        order(:email)
    end

    def overall_completion
      average_completion_score
    end

    def average_completion_score(id = nil)
      results = ActiveRecord::Base.connection.execute(average_completion_sql(id))
      results.first[avg_alias].to_f.round
    end

    private

    def inadequate_profiles_sql
      sql = ADEQUATE_FIELDS.map do |f|
        "COALESCE(cast(#{f} AS text), '') = ''"
      end.join(' OR ')
      profile_photo_missing = "( COALESCE(cast(profile_photo_id AS text), '') = '' AND " \
        "COALESCE(cast(image AS text), '') = '' )"
      sql += " OR #{profile_photo_missing}"
      sql
    end

    def avg_alias
      'average_completion_score'
    end

    def average_completion_sql(id = nil)
      sql = "SELECT AVG(( \n"
      sql += completion_score_calculation
      sql += ") * 100)::numeric(5,2) AS #{avg_alias}"
      sql += ' FROM "people"'
      if id.present?
        ids = *id
        sql += " WHERE \"people\".id IN (#{ids.join(',')})"
      end
      sql
    end

    def completion_score_calculation
      calc_sql = "(\nCOALESCE(#{completion_score_sum},0))::float/#{COMPLETION_FIELDS.size}"
      calc_sql
    end

    def completion_score_sum
      sum_sql = COMPLETION_FIELDS.each_with_object('') do |field, string|
        if field == :groups
          string.concat(' + ' + groups_exist_sql)
        elsif field == :profile_photo_present?
          string.concat(' + ' + profile_photo_present_sql)
        else
          string.concat(" + (CASE WHEN length(#{field}::varchar) > 0 THEN 1 ELSE 0 END) \n")
        end
      end

      sum_sql[2..-1]
    end

    # requires a join and therefore needs separate handling for scalability
    def groups_exist_sql
      "CASE WHEN (SELECT 1 \n" \
                  "WHERE EXISTS (SELECT 1 \n" \
                                "FROM memberships m \n" \
                                "WHERE m.person_id = people.id)) IS NOT NULL \n" \
            "THEN 1 \n" \
          "ELSE 0 \n" \
      "END \n"
    end

    # account for legacy images as well
    def profile_photo_present_sql
      "(CASE WHEN length(profile_photo_id::varchar) > 0 THEN 1 \n" \
            "WHEN length(image) > 0 THEN 1 \n" \
            "ELSE 0 \n" \
      "END)\n"
    end
  end

end
