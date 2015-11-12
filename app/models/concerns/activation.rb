module Concerns::Activation
  extend ActiveSupport::Concern

  included do
    # % of people that have completeness > 80%
    def self.activated_percentage
      acquired = Person.where("people.login_count > 0")

      if acquired.count == 0
        0
      else
        activated_count = acquired.to_a.count { |a| a.completion_score > 80 }
        (activated_count.to_f / acquired.count * 100).round(0)
      end
    end

  end
end
