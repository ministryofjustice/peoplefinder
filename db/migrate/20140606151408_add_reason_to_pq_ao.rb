class AddReasonToPqAo < ActiveRecord::Migration
  def change
    add_column :action_officers_pqs, :reason_option, :string
    rename_column :action_officers_pqs, :note, :reason
    remove_column :action_officers_pqs, :transfer
  end
end
