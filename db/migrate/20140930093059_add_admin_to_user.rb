class AddAdminToUser < ActiveRecord::Migration
  def change
    add_column 'users', 'administrator', :boolean, default: false, null: false
  end
end
