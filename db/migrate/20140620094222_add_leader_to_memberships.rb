class AddLeaderToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :leader, :boolean, default: false
  end
end