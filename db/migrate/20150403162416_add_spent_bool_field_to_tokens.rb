# This migration comes from peoplefinder (originally 20150401134903)
class AddSpentBoolFieldToTokens < ActiveRecord::Migration[4.2]
  def change
    add_column :tokens, :spent, :boolean, default: false
  end
end
