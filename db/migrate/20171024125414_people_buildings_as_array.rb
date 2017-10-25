class PeopleBuildingsAsArray < ActiveRecord::Migration
  def change
    remove_column :people, :building, :text
    add_column :people, :building, :string, array: true, default: []
  end
end
