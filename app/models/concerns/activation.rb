module Concerns::Activation
  extend ActiveSupport::Concern

  included do
    # % of people that have completeness > 80%
    def self.activated_percentage from: nil, before: nil
      acquired = Person.where("people.login_count > 0")
      acquired = acquired.where("created_at >= ?", from) if from
      acquired = acquired.where("created_at < ?", before) if before

      if acquired.count == 0
        0
      else
        activated_count = acquired.to_a.count { |a| a.completion_score > 80 }
        (activated_count.to_f / acquired.count * 100).round(0)
      end
    end

  end
end
