class CreatePressOfficers < ActiveRecord::Migration
  def change
    create_table :press_officers do |t|
      t.string :name
      t.string :email
      t.integer :press_desk_id
      t.boolean :deleted
      t.timestamps
    end
  end
end
