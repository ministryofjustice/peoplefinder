
module Concerns::GeckoboardDatasets
  extend ActiveSupport::Concern

  class_methods do

    # count of profiles created in last 6 months grouped by day created
    def total_profiles_by_day
      unscope(:order).
        group("DATE_TRUNC('day', created_at)").
        where(created_at: 6.months.ago..Date.current).
        count
    end
  end

end
