# This migration comes from peoplefinder (originally 20150211164821)
class AddUserAgentToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :user_agent, :string
  end
end
