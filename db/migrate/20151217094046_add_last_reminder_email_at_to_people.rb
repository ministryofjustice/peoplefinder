class AddLastReminderEmailAtToPeople < ActiveRecord::Migration
  def change
    add_column :people, :last_reminder_email_at, :datetime
  end
end
