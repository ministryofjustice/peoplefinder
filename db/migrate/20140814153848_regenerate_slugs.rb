class RegenerateSlugs < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def change
    remove_index 'groups', 'slug'
    remove_index 'groups', 'parent_id'
    add_index 'groups', %w[ slug parent_id ], unique: true

    Group.all.each do |group|
      group.slug = group.name.parameterize
      group.save!
    end
  end
end
