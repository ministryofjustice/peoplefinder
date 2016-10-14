class UpdateGroupMembersCompletionScoreJob < ActiveJob::Base

  # Typically this occurs if a record is deleted after the job is enqueued
  # but before it is executed (i.e. #perform called).
  rescue_from ActiveJob::DeserializationError, with: :error_handler

  queue_as :low_priority

  # update current groups score and enqueue job to update parent too
  def perform(group)
    group.update_members_completion_score!

    if group.parent && group.parent != Group.department
      UpdateGroupMembersCompletionScoreJob.perform_later(group.parent)
    end
  end

  private

  def error_handler exception
    Rails.logger.warn "#{self.class} encountered #{exception.class}: #{exception.message}"
    if exception.is_a? ActiveJob::DeserializationError
      return exception.original_exception == ActiveRecord::RecordNotFound
    else
      return false
    end
  end

end
