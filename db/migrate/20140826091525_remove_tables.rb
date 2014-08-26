class RemoveTables < ActiveRecord::Migration
  def change
    drop_table :agreements
    drop_table :budgetary_responsibilities
    drop_table :objectives
  end
end
