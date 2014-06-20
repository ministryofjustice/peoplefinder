class ChangeVersionColumnDatatypes < ActiveRecord::Migration
  def change
    change_column :versions, :item_type, :text
    change_column :versions, :event, :text
    change_column :versions, :whodunnit, :text
  end
end