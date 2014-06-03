class AddAcceptanceFieldsToPqAo < ActiveRecord::Migration
  def change
    	change_table :action_officers_pqs do |t|
    		t.boolean :accept
        t.boolean :reject
        t.boolean :transfer
        t.string :note  		
      end
    end
end