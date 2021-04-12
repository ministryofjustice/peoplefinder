class RemoveTagsFromPeople < ActiveRecord::Migration[4.2]
  def change
    remove_column :people, :tags
  end
end
