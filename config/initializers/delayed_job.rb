Delayed::Worker.queue_attributes = [
  { name: :high_priority, priority: -10 }, # lower number = higher priority
  { name: :mailers, priority: 0 }
]
