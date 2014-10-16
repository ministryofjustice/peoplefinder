class AddTagsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :tags, :text
  end
end
