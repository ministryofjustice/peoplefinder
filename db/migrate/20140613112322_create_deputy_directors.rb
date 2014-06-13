class CreateDeputyDirectors < ActiveRecord::Migration
  def change
    create_table :deputy_directors do |t|
      t.string :name
      t.string :email
      t.integer :division_id
      t.boolean :deleted
      t.timestamps
    end
  end
end
