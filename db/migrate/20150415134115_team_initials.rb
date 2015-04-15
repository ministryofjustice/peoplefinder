class TeamInitials < ActiveRecord::Migration
  def change
    add_column 'groups', 'initials', :string
  end
end
