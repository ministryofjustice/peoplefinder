class CreateExternalUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :external_users do |t|
      t.text :given_name
      t.text :surname
      t.text :slug
      t.text :email
      t.text :company
      t.boolean :admin

      t.timestamps
    end
  end
end
