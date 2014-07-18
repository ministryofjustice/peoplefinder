class AddPasswordDigestFieldToUser < ActiveRecord::Migration
  def change
  	add_column :users, :password_digest, :string, allow_null: false
  end
end
