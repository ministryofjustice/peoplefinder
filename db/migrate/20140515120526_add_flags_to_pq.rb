class AddFlagsToPq < ActiveRecord::Migration
  def change
  	change_table :pqs do |t|
  		t.boolean :press_interest
  		t.boolean :finance_interest
  		t.boolean :seen_by_press
  		t.boolean :seen_by_finance
  	end
  end
end
