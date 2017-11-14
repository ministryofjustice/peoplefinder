class AddOtherFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :people, :other_key_skills, :string
    add_column :people, :other_learning_and_development, :string
    add_column :people, :other_additional_responsibilities, :string

    remove_column :people, :key_responsibilities, :string, array: true, default: []
    add_column :people, :professions, :string, array: true, default: []
    add_column :people, :other_professions, :string
  end
end
