module Concerns::Acquisition
  extend ActiveSupport::Concern

  class_methods do
    # % of people created between specified dates (from,before)
    # and who have logged in at least once
    def acquired_percentage from: nil, before: nil
      people_count = Person.count
      (acquired_people(from: from, before: before).count.to_f / people_count * 100).round(0)
    rescue FloatDomainError, ZeroDivisionError
      0
    end

    private

    def acquired_people from: nil, before: nil
      acquired = Person.logged_in_at_least_once
      acquired = acquired.where('created_at >= ?', from) if from
      acquired = acquired.where('created_at < ?', before) if before
      acquired
    end
  end
end
