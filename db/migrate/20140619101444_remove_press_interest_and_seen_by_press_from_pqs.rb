class RemovePressInterestAndSeenByPressFromPqs < ActiveRecord::Migration
  def change
  	remove_column :pqs, :press_interest, :boolean
  	remove_column :pqs, :seen_by_press, :boolean
  end
end
