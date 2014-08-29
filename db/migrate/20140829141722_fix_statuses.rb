class FixStatuses < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE reviews
      SET status = 'rejected'
      WHERE status = 'reject';
      UPDATE reviews
      SET status = 'started'
      WHERE status IN ('accept', 'accepted')
    SQL
  end
end
