class RemoveDeletedAtColumns < ActiveRecord::Migration
  def change
    remove_column :people, :deleted_at, :datetime
    remove_column :memberships, :deleted_at, :datetime
    remove_column :groups, :deleted_at, :datetime
  end
end
