class AddDescriptionReminderEmailAtToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :description_reminder_email_at, :datetime
  end
end
