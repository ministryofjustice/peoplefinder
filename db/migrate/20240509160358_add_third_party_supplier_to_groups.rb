class AddThirdPartySupplierToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :third_party_supplier, :boolean
  end
end
