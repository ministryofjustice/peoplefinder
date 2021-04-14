class PopulateGroupMembersCompletionScore < ActiveRecord::Migration[4.2]
  def up
    Group.where(members_completion_score: nil).each do |group|
      UpdateGroupMembersCompletionScoreJob.perform_later(group)
    end
  end
end
