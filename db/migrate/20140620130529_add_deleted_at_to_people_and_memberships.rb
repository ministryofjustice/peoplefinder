class AddDeletedAtToPeopleAndMemberships < ActiveRecord::Migration
  def change
    add_column :people, :deleted_at, :datetime
    add_index :people, :deleted_at

    add_column :memberships, :deleted_at, :datetime
    add_index :memberships, :deleted_at
  end
end
