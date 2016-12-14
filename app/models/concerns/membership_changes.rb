module Concerns::MembershipChanges
  extend ActiveSupport::Concern

  included do

    after_initialize :initialize_membership_changes
    after_save :clear_membership_changes

    def membership_added
      @membership_changes[:added]
    end

    def membership_added?
      membership_added.present?
    end

    def membership_removed
      @membership_changes[:removed]
    end

    def membership_removed?
      membership_removed.present?
    end

    def membership_changed?
      membership_added? || membership_removed?
    end

    def membership_changes
      @membership_changes.deep_symbolize_keys
    end

    private

    def initialize_membership_changes
      @membership_changes = { added: [], removed: [] } if @membership_changes.nil?
    end

    def clear_membership_changes
      @membership_changes = nil
    end

    def on_add_membership membership
      initialize_membership_changes
      @membership_changes[:added] << membership.changes
    end

    def on_remove_membership membership
      initialize_membership_changes
      @membership_changes[:removed] << { group_id: [membership.group_id, nil], role: [membership.role, nil] }
    end
  end
end
