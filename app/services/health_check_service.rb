class HealthCheckService
  def initialize
    @components = []
    @components << HealthCheck::Database.new
    @components << HealthCheck::SendGrid.new
  end

  def report
    @components.each do |component|
      component.available?
      component.accessible?
    end

    errors = @components.flat_map(&:errors)

    if errors.empty?
      HealthCheckReport.new('200', 'All Components OK')
    else
      HealthCheckReport.new('500', errors)
    end
  end

  HealthCheckReport = Struct.new(:status, :messages)
end
