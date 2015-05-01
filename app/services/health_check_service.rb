class HealthCheckService


  def initialize
    @components = []
    @components << HealthCheck::Database.new
    @components << HealthCheck::SendGrid.new
    @components << HealthCheck::PqaApi.new if HealthCheck::PqaApi.time_to_run?
  end

  def report
    @components.each do |component|
      component.available?
      component.accessible?
    end

    errors = @components.map(&:error_messages).flatten

    if errors.empty?
      HealthCheckReport.new('200', 'All Components OK')
    else
      HealthCheckReport.new('500', errors)
    end
  end

  HealthCheckReport = Struct.new(:status, :messages)
end