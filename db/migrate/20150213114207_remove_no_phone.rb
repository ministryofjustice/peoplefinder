# This migration comes from peoplefinder (originally 20150212153220)
class RemoveNoPhone < ActiveRecord::Migration[4.2]
  def change
    remove_column 'people', 'no_phone'
  end
end
