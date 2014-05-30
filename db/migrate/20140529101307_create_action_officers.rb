class CreateActionOfficers < ActiveRecord::Migration
  def change
    create_table :action_officers do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
