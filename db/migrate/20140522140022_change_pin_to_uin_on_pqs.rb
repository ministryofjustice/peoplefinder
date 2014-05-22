class ChangePinToUinOnPqs < ActiveRecord::Migration
  def change
 	  remove_column :pqs, :pin
	  add_column :pqs, :uin, :string
  end
end
