class AddBudgetaryToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :budgetary_responsibilities, :hstore, array: true
  end
end
