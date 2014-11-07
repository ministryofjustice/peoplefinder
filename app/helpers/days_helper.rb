module DaysHelper
  SECONDS_IN_ONE_DAY = 24 * 60 * 60

  module_function

  def number_of_days_in_words(seconds, scope: 'helpers.days')
    if seconds < SECONDS_IN_ONE_DAY
      I18n.t('less_than_one', scope: scope)
    else
      days = (seconds / SECONDS_IN_ONE_DAY).floor
      I18n.t('one_or_more', count: days, scope: scope)
    end
  end
end
