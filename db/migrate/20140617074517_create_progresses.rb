class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
      t.string :name
      t.integer :progress_order

      t.timestamps
    end
  end
end
