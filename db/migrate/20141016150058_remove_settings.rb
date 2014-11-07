class RemoveSettings < ActiveRecord::Migration
  def change
    drop_table :settings
  end
end
