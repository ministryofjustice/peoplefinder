class RestoreSlugIndexToGroups < ActiveRecord::Migration
  Group.all.each do |group|
    group.slug = nil
    group.save!
  end

  def change
    add_index :groups, :slug
  end
end
