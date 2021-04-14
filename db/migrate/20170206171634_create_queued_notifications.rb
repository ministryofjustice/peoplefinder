class CreateQueuedNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :queued_notifications do |t|
      t.string :email_template
      t.string :session_id
      t.integer :person_id
      t.integer :current_user_id
      t.text :changes_json
      t.boolean :edit_finalised, default: false
      t.datetime :processing_started_at, default: nil
      t.boolean :sent, default: false

      t.timestamps null: false
    end
  end
end
