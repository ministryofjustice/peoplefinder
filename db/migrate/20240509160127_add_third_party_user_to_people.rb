class AddThirdPartyUserToPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :third_party_user, :boolean
  end
end
