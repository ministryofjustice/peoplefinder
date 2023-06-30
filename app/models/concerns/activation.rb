module Concerns::Activation
  extend ActiveSupport::Concern

  class_methods do
    # % of "acquired" people that have completeness > 80%
    def activated_percentage(from: nil, before: nil)
      acquired = acquired_people(from:, before:)
      activated_count = acquired.where("#{completion_score_calculation} > ?", 0.8).count
      (activated_count.to_f / acquired.count * 100).round(0)
    rescue FloatDomainError, ZeroDivisionError
      0.0
    end
  end
end
