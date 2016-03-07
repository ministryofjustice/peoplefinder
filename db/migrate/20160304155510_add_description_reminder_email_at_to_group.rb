class AddDescriptionReminderEmailAtToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :description_reminder_email_at, :datetime
  end
end
