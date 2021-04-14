# This migration comes from peoplefinder (originally 20141016102351)
class AddTagsToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :tags, :text
  end
end
