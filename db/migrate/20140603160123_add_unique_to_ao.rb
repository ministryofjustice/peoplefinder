class AddUniqueToAo < ActiveRecord::Migration
  def change
    add_index :action_officers, :email, unique: true
  end
end
