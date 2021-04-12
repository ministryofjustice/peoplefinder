class RemoveInvalidRelationships < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL.strip_heredoc
      DELETE FROM memberships
      WHERE person_id IS NULL
      OR person_id NOT IN (SELECT id FROM people)
      OR group_id IS NULL
      OR group_id NOT IN (SELECT id FROM groups);
    SQL
  end
end
