class CreateSearchIndex < ActiveRecord::Migration
  def change
    create_table :search_index do |t|
      t.references :person
      t.string :name
      t.column "document", :tsvector
    end
    add_index :search_index, :person_id, unique: true
  end
end
