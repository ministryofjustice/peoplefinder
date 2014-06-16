class AddMinisterIdsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :minister_id, :integer
    add_column :pqs, :policy_minister_id, :integer
  end
end
