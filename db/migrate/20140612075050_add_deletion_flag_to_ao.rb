class AddDeletionFlagToAo < ActiveRecord::Migration
  def change
  	add_column :action_officers, :deleted, :boolean
  end
end
