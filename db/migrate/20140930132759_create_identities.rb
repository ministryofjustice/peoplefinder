class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.text :username, null: false
      t.text :password_digest, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :identities, [:username], unique: true
  end
end
