class CreatePressDesks < ActiveRecord::Migration
  def change
    create_table :press_desks do |t|
      t.string :name
	  t.boolean :deleted
      t.timestamps
    end
  end
end
