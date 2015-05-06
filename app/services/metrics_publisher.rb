class MetricsPublisher
  def initialize(recipient = Keen)
    @recipient = recipient
  end

  def publish!
    @recipient.publish :completion, completion_report
  end

private

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
