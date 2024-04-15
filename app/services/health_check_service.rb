class HealthCheckService
  def initialize
    @components = []
    @components << HealthCheck::Database.new
    @components << HealthCheck::OpenSearch.new
  end

  def report
    @components.each do |component|
      component.available?
      component.accessible?
    end

    errors = @components.flat_map(&:errors)

    if errors.empty?
      HealthCheckReport.new("200", "All Components OK")
    else
      Sentry.capture_message(errors)
      HealthCheckReport.new("500", errors)
    end
  rescue StandardError => e
    Sentry.capture_message(e)
    HealthCheckReport.new("500", e)
  end

  HealthCheckReport = Struct.new(:status, :messages)
end
