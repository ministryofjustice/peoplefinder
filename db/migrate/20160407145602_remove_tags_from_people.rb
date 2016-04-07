class RemoveTagsFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :tags
  end
end
