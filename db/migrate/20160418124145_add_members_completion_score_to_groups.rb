class AddMembersCompletionScoreToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :members_completion_score, :integer
  end
end
