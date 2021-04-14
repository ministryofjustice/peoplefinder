class AddCurrentProjectToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :current_project, :string
  end
end
