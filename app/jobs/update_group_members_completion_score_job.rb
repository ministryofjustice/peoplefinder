class UpdateGroupMembersCompletionScoreJob < ActiveJob::Base
  queue_as :low_priority

  def perform(group)
    group.update_members_completion_score!
  end
end
