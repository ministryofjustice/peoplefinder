class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.text :value
      t.text :user_email
      t.timestamps
    end
  end
end
