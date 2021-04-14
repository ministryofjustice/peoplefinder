# This migration comes from peoplefinder (originally 20150303153605)
class DropReportedProfiles < ActiveRecord::Migration[4.2]
  def up
    drop_table :reported_profiles
  end

  def down
    create_table "reported_profiles" do |t|
      t.integer "notifier_id"
      t.integer "subject_id"
      t.string  "recipient_email"
      t.text    "reason_for_reporting"
      t.text    "additional_details"
    end
  end
end
