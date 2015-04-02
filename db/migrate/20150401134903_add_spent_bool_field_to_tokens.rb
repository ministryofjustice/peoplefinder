class AddSpentBoolFieldToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :spent, :boolean, default: false
  end
end
