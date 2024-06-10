class CreateExternalUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :external_users do |t|
      t.text :email

      t.timestamps
    end
  end
end
