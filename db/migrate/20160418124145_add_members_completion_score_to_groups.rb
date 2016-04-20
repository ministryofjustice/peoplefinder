class AddMembersCompletionScoreToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :members_completion_score, :integer
  end
end
