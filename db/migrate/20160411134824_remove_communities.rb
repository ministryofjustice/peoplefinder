class RemoveCommunities < ActiveRecord::Migration
  def change
    remove_column :people, :community_id

    drop_table "communities"
  end
end
