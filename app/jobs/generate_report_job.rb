class GenerateReportJob < ApplicationJob
  queue_as :generate_report

  def perform(report)
    report = report.constantize
    report.publish!
  end

  def max_attempts
    3
  end

  def max_run_time
    10.minutes
  end

  def destroy_failed_jobs?
    true
  end
end
