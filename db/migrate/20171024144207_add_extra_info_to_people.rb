class AddExtraInfoToPeople < ActiveRecord::Migration
  def change
    add_column :people, :key_skills, :string, array: true, default: []
    add_column :people, :language_fluent, :text
    add_column :people, :language_intermediate, :text
    add_column :people, :grade, :text
    add_column :people, :previous_positions, :text
    add_column :people, :learning_and_development, :string, array: true, default: []
    add_column :people, :networks, :string, array: true, default: []
    add_column :people, :key_responsibilities, :string, array: true, default: []
    add_column :people, :additional_responsibilities, :string, array: true, default: []
  end
end
