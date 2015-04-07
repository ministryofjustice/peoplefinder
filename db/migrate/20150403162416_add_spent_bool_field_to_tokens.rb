# This migration comes from peoplefinder (originally 20150401134903)
class AddSpentBoolFieldToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :spent, :boolean, default: false
  end
end
