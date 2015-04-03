module ActiveJobHelper
  extend ActiveSupport::Concern

  included do
    around do |example|
      clear_enqueued_jobs
      clear_performed_jobs

      perform_enqueued_jobs do
        example.run
      end
    end
  end

  def perform_enqueued_jobs
    @old_perform_enqueued_jobs = queue_adapter.perform_enqueued_jobs
    @old_perform_enqueued_at_jobs = queue_adapter.perform_enqueued_at_jobs
    queue_adapter.perform_enqueued_jobs = true
    queue_adapter.perform_enqueued_at_jobs = true
    yield
  ensure
    queue_adapter.perform_enqueued_jobs = @old_perform_enqueued_jobs
    queue_adapter.perform_enqueued_at_jobs = @old_perform_enqueued_at_jobs
  end

  delegate :enqueued_jobs, :performed_jobs, to: :queue_adapter

  def clear_enqueued_jobs
    enqueued_jobs.clear
  end

  def clear_performed_jobs
    performed_jobs.clear
  end

  def queue_adapter
    ActiveJob::Base.queue_adapter
  end
end
