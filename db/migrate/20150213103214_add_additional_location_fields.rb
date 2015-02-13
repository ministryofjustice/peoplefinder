class AddAdditionalLocationFields < ActiveRecord::Migration
  def change
    rename_column 'people', 'location', 'location_in_building'
    add_column 'people', 'building', :text
    add_column 'people', 'city', :text
  end
end
