class MetricsPublisher
  def initialize(recipient = Keen)
    @recipient = recipient
  end

  def publish!
    @recipient.publish :completion, completion_report
    @recipient.publish :profiles, profiles_report
  end

  # private #TODO make private again eventually

  def profiles_report
    {
      'total' => Person.count,
      'not_logged_in' => Person.never_logged_in.count
    }
  end

  def completion_report
    report = { 'mean' => Person.overall_completion }
    report.merge! Person.bucketed_completion_scores
  end

  # TODO - remove when sure we do not need this explicit format
  # def range_to_string(range)
  #   '[%d,%d%s' % [range.begin, range.end, range.exclude_end? ? ')' : ']']
  # end
end
