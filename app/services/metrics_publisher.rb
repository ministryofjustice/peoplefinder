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
    report['completions_by_range'] = Person.bucketed_completion.map do |range, total|
      { 'range' => "#{range.begin}..#{range.end}",
        'total' => total }
    end
    report
  end
end
