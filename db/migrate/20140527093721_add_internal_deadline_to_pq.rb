class AddInternalDeadlineToPq < ActiveRecord::Migration
  def change
    add_column :pqs, :internal_deadline, :datetime
  end
end
