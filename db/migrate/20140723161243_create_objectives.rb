class CreateObjectives < ActiveRecord::Migration
  def change
    create_table :objectives do |t|
      t.string :objective_type
      t.text :description
      t.text :deliverables
      t.text :measurements
      t.belongs_to :agreement
      t.timestamps
    end

    add_index :objectives, :objective_type
  end
end
