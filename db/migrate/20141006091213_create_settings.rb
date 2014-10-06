class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.text :key, null: false
      t.text :value

      t.timestamps
    end

    add_index :settings, :key, unique: true
  end
end
