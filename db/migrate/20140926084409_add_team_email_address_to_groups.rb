class AddTeamEmailAddressToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :team_email_address, :text

    execute "UPDATE groups
             SET team_email_address = '#{ Rails.configuration.support_email }'"
  end

  def down
    remove_column :groups, :team_email_address
  end
end
