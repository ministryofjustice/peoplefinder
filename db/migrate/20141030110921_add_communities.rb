# This migration comes from peoplefinder (originally 20141029113248)
class AddCommunities < ActiveRecord::Migration
  def change
    create_table "communities", force: true do |t|
      t.string  "name"
      t.timestamps
    end

    add_column :people, :community_id, :integer
  end
end
