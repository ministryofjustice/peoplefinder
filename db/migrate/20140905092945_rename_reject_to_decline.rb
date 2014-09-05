class RenameRejectToDecline < ActiveRecord::Migration
  def change
    rename_column :reviews, :rejection_reason, :reason_declined
    execute <<-SQL
      UPDATE reviews
      SET status = 'declined'
      WHERE status = 'rejected'
    SQL
  end
end
