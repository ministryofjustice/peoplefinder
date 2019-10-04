Delayed::Worker.queue_attributes = {
  high_priority: { priority: -10 }, # lower number = higher priority
  mailers: { priority: 0 },
  low_priority: { priority: 10 }, # higher number = lower priority
  person_import: { priority: -11 },
  generate_report: { priority: -11 }
}

Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log')) if Rails.env.development?
