Delayed::Worker.queue_attributes = [
  { name: :high_priority, priority: -10 }, # lower number = higher priority
  { name: :mailers, priority: 0 },
  { name: :low_priority, priority: 10 }, # higher number = lower priority
  { name: :person_import, priority: -11 },
  { name: :generate_report, priority: -11 }
]

Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log')) if Rails.env.development?
