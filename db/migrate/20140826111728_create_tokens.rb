class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.text :value
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
