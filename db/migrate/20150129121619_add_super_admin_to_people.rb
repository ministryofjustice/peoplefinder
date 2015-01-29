class AddSuperAdminToPeople < ActiveRecord::Migration
  def change
    add_column :people, :super_admin, :boolean, default: false
  end
end
