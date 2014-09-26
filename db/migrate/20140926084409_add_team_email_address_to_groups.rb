class AddTeamEmailAddressToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :team_email_address, :text

    execute "UPDATE groups
             SET team_email_address = 'people-finder@digital.justice.gov.uk'"
  end

  def down
    remove_column :groups, :team_email_address
  end
end
