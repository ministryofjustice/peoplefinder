class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.belongs_to :parent, index: true
      t.text :name

      t.timestamps
    end
  end
end
