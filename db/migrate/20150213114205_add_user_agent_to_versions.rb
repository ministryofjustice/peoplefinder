# This migration comes from peoplefinder (originally 20150211164821)
class AddUserAgentToVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :user_agent, :string
  end
end
