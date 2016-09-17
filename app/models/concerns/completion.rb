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

  BUCKETS = [0..19, 20..49, 50..79, 80..100].freeze

  included do
    def self.inadequate_profiles
      where(inadequate_profiles_sql).
      order(:email)
    end

    # This is not scalable
    # def self.overall_completion
    #   all.map(&:completion_score).inject(0.0, &:+) / count
    # end

    # scalable - fast
    def self.overall_completion
      average_completion_score
    end

    # This is not scalable
    # def self.bucketed_completion
    #   results = Hash[BUCKETS.map { |r| [r, 0] }]
    #   all.map(&:completion_score).each do |score|
    #     bucket = BUCKETS.find { |b| b.include?(score) }
    #     results[bucket] += 1
    #   end
    #   results
    # end

    # This is not scalable
    # def completion_score
    #   completed = COMPLETION_FIELDS.map { |f| send(f).present? }
    #   (100 * completed.count { |f| f }) / COMPLETION_FIELDS.length
    # end

    def completion_score
      self.class.average_completion_score(id)
    end

    # scalable
    def self.average_completion_score id=nil
      results = ActiveRecord::Base.connection.execute(average_completion_sql id)
      results.first[avg_alias].to_f.round
    end

    def self.bucketed_completion
      results = ActiveRecord::Base.connection.execute(bucketed_completion_score_sql)
      parse_bucketed_results results
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

    private

    def self.inadequate_profiles_sql
      sql = ADEQUATE_FIELDS.map do |f|
        "COALESCE(cast(#{f} AS text), '') = ''"
      end.join(' OR ')
      profile_photo_missing = "( COALESCE(cast(profile_photo_id AS text), '') = '' AND " \
        "COALESCE(cast(image AS text), '') = '' )"
      sql += " OR #{profile_photo_missing}"
    end

    def self.avg_alias
      'average_completion_score'
    end

    def self.average_completion_sql id=nil
      sql = "SELECT AVG(( \n"
      sql += completion_score_calculation
      sql += ") * 100)::numeric(5,2) AS #{avg_alias}"
      sql += " FROM \"people\""
      if id.present?
        ids = *id
        sql += " WHERE \"people\".id IN (#{ids.join(',')})"
      end
      sql
    end

    def self.completion_score_calculation
      calc_sql = "(\nCOALESCE(#{completion_score_sum},0))::float/#{COMPLETION_FIELDS.size}"
      calc_sql
    end

    # NOTE: - groups "field" requires a join and therefore needs separate handling for scalability
    #       - photo "field" requires checking for legacy images as well
    def self.completion_score_sum
       sum_sql = COMPLETION_FIELDS.each_with_object(String.new) do |field, string|
        if field == :groups
          string.concat(" + CASE WHEN (SELECT 1 WHERE EXISTS (SELECT 1 FROM memberships m WHERE m.person_id = people.id)) IS NOT NULL THEN 1 ELSE 0 END \n")
        elsif field == :profile_photo_present?
          string.concat(" + (CASE WHEN length(profile_photo_id::varchar) > 0 THEN 1 \n" +
                                "WHEN length(image) > 0 THEN 1 \n" +
                                "ELSE 0 \n" +
                            "END)")
        else
          string.concat(" + (CASE WHEN length(#{field}::varchar) > 0 THEN 1 ELSE 0 END) \n")
        end
      end

      sum_sql[2..-1]
    end

    def self.bucket_case_statement alias_name=avg_alias
      BUCKETS.inject('CASE') do |memo, range|
        memo + "\nWHEN #{alias_name} BETWEEN #{range.begin} AND #{range.end} THEN \'[#{range.begin},#{range.end}]\'"
      end + "\nEND AS bucket\n"
    end

    def self.bucketed_completion_score_sql
      "SELECT people_count," +
      bucket_case_statement(avg_alias) +
      "FROM (
        SELECT count(id) AS people_count, \n" +
        "(#{completion_score_calculation} * 100)::numeric(5,2) AS #{avg_alias} \n" +
        " FROM \"people\" GROUP BY (#{avg_alias}) \n" +
      ") AS buckets"
    end

    def self.parse_bucketed_results results
      results = results.inject(Hash.new) { |memo, tuple| memo.merge( tuple['bucket'] => tuple['people_count'].to_i) }
      default_bucket_scores.merge results
    end

    def self.default_bucket_scores
      Hash[Person::BUCKETS.map { |r| ["[#{r.begin},#{r.end}]", 0] }]
    end

  end
end
