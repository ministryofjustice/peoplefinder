class RemoveCommunities < ActiveRecord::Migration[4.2]
  def change
    remove_column :people, :community_id

    drop_table "communities"
  end
end
