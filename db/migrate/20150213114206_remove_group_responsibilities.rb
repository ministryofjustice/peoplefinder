# This migration comes from peoplefinder (originally 20150212132353)
class RemoveGroupResponsibilities < ActiveRecord::Migration[4.2]
  def change
    remove_column 'groups', 'responsibilities'
  end
end
