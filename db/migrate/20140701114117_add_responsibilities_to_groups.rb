class AddResponsibilitiesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :responsibilities, :text
  end
end
