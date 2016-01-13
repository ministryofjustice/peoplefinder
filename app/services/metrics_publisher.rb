class MetricsPublisher
  def initialize(recipient = Keen)
    @recipient = recipient
  end

  def publish!
    @recipient.publish :completion, completion_report
    @recipient.publish :profiles, profiles_report
  end

  private

  def profiles_report
    {
      'total' => Person.count,
      'not_logged_in' => Person.where(login_count: 0).count
    }
  end

  def completion_report
    report = { 'mean' => Person.overall_completion }
    Person.bucketed_completion.each do |range, total|
      report[range_to_string(range)] = total
    end
    report
  end

  def range_to_string(range)
    '[%d,%d%s' % [range.begin, range.end, range.exclude_end? ? ')' : ']']
  end
end
