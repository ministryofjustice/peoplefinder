class RenameJobholderToStaffMember < ActiveRecord::Migration
  def change
    rename_column "agreements", "jobholder_id", "staff_member_id"
  end
end
