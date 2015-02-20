class RemoveTeamEmailAddressFromGroup < ActiveRecord::Migration
  def change
    remove_column :groups, :team_email_address
  end
end
