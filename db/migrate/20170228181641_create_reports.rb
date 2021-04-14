class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.text :content
      t.string :name
      t.string :extension
      t.string :mime_type

      t.timestamps null: false
    end
  end
end
