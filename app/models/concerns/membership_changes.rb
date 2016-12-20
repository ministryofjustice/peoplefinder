module Concerns::MembershipChanges
  extend ActiveSupport::Concern

  included do

    after_initialize :initialize_membership_changes
    after_save :clear_membership_changes

    def membership_changes
      @membership_changes.deep_symbolize_keys unless @membership_changes.nil?
    end

    private

    def initialize_membership_changes
      @membership_changes = {} if @membership_changes.nil?
    end

    def clear_membership_changes
      @membership_changes = nil
    end

    def store_membership_addition membership
      initialize_membership_changes
      @membership_changes["membership_#{membership.object_id}".to_sym] = membership.changes
    end

    def store_membership_removal membership
      initialize_membership_changes
      @membership_changes["membership_#{membership.object_id}".to_sym] = removal_changes membership
    end

    def removal_changes membership
      { group_id: [membership.group_id, nil], role: [membership.role, nil] }
    end
  end
end
