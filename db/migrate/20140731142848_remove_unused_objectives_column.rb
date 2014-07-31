class RemoveUnusedObjectivesColumn < ActiveRecord::Migration
  def change
    remove_column 'agreements', 'objectives'
  end
end
