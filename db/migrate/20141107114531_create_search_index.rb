class CreateSearchIndex < ActiveRecord::Migration
  def change
    create_table :search_index do |t|
      t.references :person
      t.string :name
      t.column "document", :tsvector
    end
  end
end
