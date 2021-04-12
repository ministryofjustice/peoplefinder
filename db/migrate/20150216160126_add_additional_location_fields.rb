# This migration comes from peoplefinder (originally 20150213103214)
class AddAdditionalLocationFields < ActiveRecord::Migration[4.2]
  def change
    rename_column 'people', 'location', 'location_in_building'
    add_column 'people', 'building', :text
    add_column 'people', 'city', :text
  end
end
