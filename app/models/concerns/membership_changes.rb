module Concerns::MembershipChanges
  extend ActiveSupport::Concern

  included do

    after_initialize :initialize_membership_changes

    before_save do
      @membership_changes = memberships.inject({}) do |memo, membership|
        memo[membership_key(membership)] = membership.changes if membership.changed?
        memo
      end
    end

    def membership_key membership
      "membership_#{membership.group_id || membership.changes[:group_id]&.second || membership.changes[:group_id]&.first }"
    end

    def membership_changes
      @membership_changes.deep_symbolize_keys unless @membership_changes.nil?
    end

    private

    def initialize_membership_changes
      @membership_changes = {} if @membership_changes.nil?
    end
  end
end
