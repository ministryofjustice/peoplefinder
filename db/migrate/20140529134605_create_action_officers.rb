class CreateActionOfficers < ActiveRecord::Migration
  def change
    create_table :action_officers do |t|

      t.timestamps
    end
  end
end
