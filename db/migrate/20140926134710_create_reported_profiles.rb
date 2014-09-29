class CreateReportedProfiles < ActiveRecord::Migration
  def change
    create_table :reported_profiles do |t|
      t.belongs_to :notifier
      t.belongs_to :subject
      t.string :recipient_email
      t.text :reason_for_reporting
      t.text :additional_details
    end
  end
end
