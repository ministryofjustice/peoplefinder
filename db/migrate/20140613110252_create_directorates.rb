class CreateDirectorates < ActiveRecord::Migration
  def change
    create_table :directorates do |t|
      t.string :name
      t.boolean :deleted
      t.timestamps
    end
  end
end
