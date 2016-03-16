class AddCurrentProjectToPerson < ActiveRecord::Migration
  def change
    add_column :people, :current_project, :string
  end
end
