class AddMetaFieldsToActionOfficers < ActiveRecord::Migration
  def change
    add_column :action_officers, :phone, :string
    add_column :action_officers, :deputy_director_id, :integer
  end
end
