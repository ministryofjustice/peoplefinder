Delayed::Worker.queue_attributes = {
  high_priority: { priority: -10 },
  mailers: { priority: 0 },
  low_priority: { priority: 10 },
  person_import: { priority: -11 },
  generate_report: { priority: -11 }
}

Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(Rails.root.join('log/delayed_job.log')) if ENV['ENV'] != 'production'
