class AddGradeAndOrganisationToUser < ActiveRecord::Migration
  def change
    add_column :users, :grade, :text
    add_column :users, :organisation, :text
  end
end