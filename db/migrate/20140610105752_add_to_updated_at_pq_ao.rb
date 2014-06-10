class AddToUpdatedAtPqAo < ActiveRecord::Migration
  def change
    add_column :action_officers_pqs, :updated_at, :datetime
    add_column :action_officers_pqs, :created_at, :datetime
  end
end
