module Concerns::Acquisition
  extend ActiveSupport::Concern

  included do
    # % of people who have logged in at least once
    def self.acquired_percentage from: nil, before: nil
      people_count = Person.count
      if people_count == 0
        0.0
      else
        (acquired_count(from: from, before: before).to_f / people_count * 100).round(0)
      end
    end

    def self.acquired_count from: nil, before: nil
      acquired = Person.where("people.login_count > 0")
      acquired = acquired.where("created_at >= ?", from) if from
      acquired = acquired.where("created_at < ?", before) if before
      acquired.count
    end

  end
end
