class AddIpAddressToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :ip_address, :string
  end
end
