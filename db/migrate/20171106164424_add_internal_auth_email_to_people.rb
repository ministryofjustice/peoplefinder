class AddInternalAuthEmailToPeople < ActiveRecord::Migration
  def change
    add_column :people, :internal_auth_key, :string, index: true
  end
end
