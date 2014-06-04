class PrimaryKeyForPqAo < ActiveRecord::Migration
  def change
    add_column :action_officers_pqs, :id, :primary_key
  end
end
