class AddInternalAuthEmailToPeople < ActiveRecord::Migration
  def change
    add_column :people, :internal_auth_email, :string, index: true
  end
end
