class RemoveGroupResponsibilities < ActiveRecord::Migration
  def change
    remove_column 'groups', 'responsibilities'
  end
end
