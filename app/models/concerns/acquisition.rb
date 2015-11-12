module Concerns::Acquisition
  extend ActiveSupport::Concern

  included do
    # % of people who have logged in at least once
    def self.acquired_percentage
      people_count = Person.count
      if people_count == 0
        0.0
      else
        acquired_count = Person.where("people.login_count > 0").count
        (acquired_count.to_f / people_count * 100).round(0)
      end
    end

  end
end
