class AddAncestryToGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_ancestry cache_depth: true
  end

  def change
    add_column :groups, :ancestry, :text
    add_column :groups, :ancestry_depth, :integer, default: 0, null: false
    add_index :groups, :ancestry
    Group.build_ancestry_from_parent_ids!
    Group.rebuild_depth_cache!
    remove_column :groups, :parent_id
  end
end
