class AddStaffNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :staff_number, :string
  end
end