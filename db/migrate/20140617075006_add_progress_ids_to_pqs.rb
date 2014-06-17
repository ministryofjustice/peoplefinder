class AddProgressIdsToPqs < ActiveRecord::Migration
  def change
    add_column :pqs, :progress_id, :integer
  end
end
