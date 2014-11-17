class AddLoginCountAndLastLoginAtToPerson < ActiveRecord::Migration
  def change
    add_column :people, :login_count, :integer, default: 0, null: false
    add_column :people, :last_login_at, :datetime, null: true
  end
end
