class AddUserAgentToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :user_agent, :string
  end
end
