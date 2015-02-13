class RemoveNoPhone < ActiveRecord::Migration
  def change
    remove_column 'people', 'no_phone'
  end
end
