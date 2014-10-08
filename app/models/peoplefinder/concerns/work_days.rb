require 'peoplefinder'

module Peoplefinder::Concerns::WorkDays
  extend ActiveSupport::Concern

  included do
    WEEK_DAYS = [
      :works_monday,
      :works_tuesday,
      :works_wednesday,
      :works_thursday,
      :works_friday
    ]

    DAYS_WORKED = [
      *WEEK_DAYS,
      :works_saturday,
      :works_sunday
    ]

    def works_weekends?
      works_saturday || works_sunday
    end
  end
end
