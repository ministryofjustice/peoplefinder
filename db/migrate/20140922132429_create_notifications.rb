class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :recipient
      t.string :sender_email
      t.text :message
      t.string :type
    end

    add_index :notifications, :type
    add_index :notifications, :sender_email
  end
end
