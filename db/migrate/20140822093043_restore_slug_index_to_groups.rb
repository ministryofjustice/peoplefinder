class RestoreSlugIndexToGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base

    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    has_ancestry cache_depth: true

    def slug_candidates
      candidates = [name]
      candidates <<  [parent.name, name] if parent.present?
      candidates
    end
  end

  def change
   Group.all.each do |group|
      group.slug = nil
      group.save
    end

    add_index :groups, :slug
  end
end
