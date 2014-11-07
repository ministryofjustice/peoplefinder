module SpecSupport
  module ReviewPeriod
    def close_review_period
      ::ReviewPeriod.closes_at = Time.now - 600
    end

    def open_review_period
      ::ReviewPeriod.closes_at = Time.now + 600
    end
  end
end
