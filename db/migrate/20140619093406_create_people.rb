class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.text :given_name
      t.text :surname
      t.text :email
      t.text :phone
      t.text :mobile
      t.text :location
      t.text :keywords
      t.text :description
      t.timestamps
    end
  end
end
