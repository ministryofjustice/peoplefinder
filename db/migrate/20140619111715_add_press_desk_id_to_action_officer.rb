class AddPressDeskIdToActionOfficer < ActiveRecord::Migration
  def change
    add_column :action_officers, :press_desk_id, :integer
  end
end
