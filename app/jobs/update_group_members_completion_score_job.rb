class UpdateGroupMembersCompletionScoreJob < ActiveJob::Base

  queue_as :low_priority

  def perform(group)
    group.update_members_completion_score!

    if group.parent && group.parent != Group.department
      UpdateGroupMembersCompletionScoreJob.perform_later(group.parent)
    end
  end
end
