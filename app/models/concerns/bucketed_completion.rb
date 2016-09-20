module Concerns::BucketedCompletion
  extend ActiveSupport::Concern

  BUCKETS = [0..19, 20..49, 50..79, 80..100].freeze

  class_methods do
    def bucketed_completion
      results = ActiveRecord::Base.connection.execute(bucketed_completion_score_sql)
      parse_bucketed_results results
    end

    private

    def bucket_case_statement(alias_name = avg_alias)
      BUCKETS.inject('CASE') do |memo, range|
        memo + "\nWHEN #{alias_name} BETWEEN #{range.begin} AND #{range.end} THEN \'[#{range.begin},#{range.end}]\'"
      end + "\nEND AS bucket\n"
    end

    def bucketed_completion_score_sql
      <<-SQL
      SELECT people_count,
        #{bucket_case_statement(avg_alias)}
        FROM (
          SELECT count(id) AS people_count,
          (#{completion_score_calculation} * 100)::numeric(5,2) AS #{avg_alias}
          FROM \"people\" GROUP BY (#{avg_alias})
        ) AS buckets
      SQL
    end

    def parse_bucketed_results results
      results = results.inject({}) { |memo, tuple| memo.merge(tuple['bucket'] => tuple['people_count'].to_i) }
      default_bucket_scores.merge results
    end

    def default_bucket_scores
      Hash[BUCKETS.map { |r| ["[#{r.begin},#{r.end}]", 0] }]
    end
  end

end
