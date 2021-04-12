# This migration comes from peoplefinder (originally 20150219154520)
class RemoveTeamEmailAddressFromGroup < ActiveRecord::Migration[4.2]
  def change
    remove_column :groups, :team_email_address
  end
end
