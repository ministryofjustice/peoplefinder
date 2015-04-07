module Concerns::Hierarchical
  extend ActiveSupport::Concern

  included do
    has_ancestry cache_depth: true

    def leaf_node?
      children.blank?
    end
  end
end
