class CreateBudgetaryResponsibilities < ActiveRecord::Migration
  def change
    create_table :budgetary_responsibilities do |t|
      t.belongs_to :agreement, index: true
      t.string :budget_type
      t.integer :value
      t.text :description

      t.timestamps
    end

    remove_column :agreements, :budgetary_responsibilities
  end
end
