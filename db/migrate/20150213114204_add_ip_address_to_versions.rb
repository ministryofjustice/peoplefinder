# This migration comes from peoplefinder (originally 20150211153741)
class AddIpAddressToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :ip_address, :string
  end
end
