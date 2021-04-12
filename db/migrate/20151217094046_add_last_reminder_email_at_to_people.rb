class AddLastReminderEmailAtToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :last_reminder_email_at, :datetime
  end
end
