module Concerns::WorkDays
  extend ActiveSupport::Concern

  WEEK_DAYS = %i[
    works_monday
    works_tuesday
    works_wednesday
    works_thursday
    works_friday
  ].freeze

  DAYS_WORKED = [
    *WEEK_DAYS,
    :works_saturday,
    :works_sunday,
  ].freeze

  included do
    def works_weekends?
      works_saturday || works_sunday
    end
  end
end
