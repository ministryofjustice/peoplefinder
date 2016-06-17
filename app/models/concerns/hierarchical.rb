module Concerns::Hierarchical
  extend ActiveSupport::Concern

  included do
    has_ancestry cache_depth: true

    def leaf_node?
      children.blank?
    end

    # NOTE: ancestry gem does not work with find_or_create_by[!].
    # see https://github.com/stefankroes/ancestry#organising-records-into-a-tree
    # So we extend the model with find_or_create_by! to apply the ancestry
    # gem's logic for parent attributes
    # e.g. The following would only ever create one child of the parent:
    # Group.find_or_create_by!(name: 'Content', parent: digital_services )
    # Group.find_or_create_by!(name: 'Content', parent: technology )
    def self.find_or_create_by! attributes, &block
      return super unless attributes.include?(:parent) || attributes.include?(:parent_id)
      parent = attributes.delete(:parent) if attributes.include?(:parent)
      parent_id = attributes.delete(:parent_id) if attributes.include?(:parent_id)
      parent_id = parent.id if parent_id.nil?

      if find_by(attributes) && (find_by(attributes).parent_id == parent_id || find_by(attributes).parent == parent)
        find_by(attributes)
      else
        create!(attributes.merge(parent_id: parent_id), &block)
      end
    end

  end
end
