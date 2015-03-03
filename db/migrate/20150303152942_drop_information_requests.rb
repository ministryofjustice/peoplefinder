class DropInformationRequests < ActiveRecord::Migration
  def up
    drop_table :information_requests
  end

  def down
    create_table "information_requests" do |t|
      t.integer "recipient_id"
      t.string  "sender_email"
      t.text    "message"
      t.string  "type"
    end
  end
end
