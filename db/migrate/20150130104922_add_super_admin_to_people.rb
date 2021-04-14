# This migration comes from peoplefinder (originally 20150129121619)
class AddSuperAdminToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :super_admin, :boolean, default: false
  end
end
