class AddParticipantToUsers < ActiveRecord::Migration
  def up
    add_column :users, :participant, :boolean, default: false

    execute <<-SQL
      UPDATE users
      SET participant = true
      WHERE manager_id is not null
      OR id IN (SELECT DISTINCT manager_id from users)
    SQL
  end

  def down
    remove_column :users, :participant
  end
end