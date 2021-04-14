# This migration comes from peoplefinder (originally 20141112170526)
class AddLoginCountAndLastLoginAtToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :login_count, :integer, default: 0, null: false
    add_column :people, :last_login_at, :datetime, null: true
  end
end
