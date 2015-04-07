# This migration comes from peoplefinder (originally 20150129121619)
class AddSuperAdminToPeople < ActiveRecord::Migration
  def change
    add_column :people, :super_admin, :boolean, default: false
  end
end
