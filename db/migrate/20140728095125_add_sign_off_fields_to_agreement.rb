class AddSignOffFieldsToAgreement < ActiveRecord::Migration
  def change
    add_column "agreements", "responsibilities_signed_off_by_staff_member", :boolean, null: false, default: false
    add_column "agreements", "responsibilities_signed_off_by_manager", :boolean, null: false, default: false
    add_column "agreements", "objectives_signed_off_by_staff_member", :boolean, null: false, default: false
    add_column "agreements", "objectives_signed_off_by_manager", :boolean, null: false, default: false
  end
end
