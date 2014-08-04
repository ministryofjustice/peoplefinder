class RenamePhoneNumberFields < ActiveRecord::Migration
  def change
    rename_column :people, :phone, :primary_phone_number
    rename_column :people, :mobile, :secondary_phone_number
  end
end