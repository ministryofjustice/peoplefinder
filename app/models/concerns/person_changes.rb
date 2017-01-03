module Concerns::PersonChanges
  extend ActiveSupport::Concern

  included do

    after_initialize :initialize_changes_store

    before_save do
      @person_changes = changes
      @membership_changes = memberships.each_with_object({}) do |membership, h|
        h[membership_key(membership)] = membership.changes if membership.changed?
      end
    end

    def person_changes
      @person_changes.deep_symbolize_keys unless @person_changes.nil?
    end

    def membership_changes
      @membership_changes.deep_symbolize_keys unless @membership_changes.nil?
    end

    def all_changes
      person_changes.merge(membership_changes)
    end

    private

    def initialize_changes_store
      @person_changes = {} if @person_changes.nil?
      @membership_changes = {} if @membership_changes.nil?
    end

    def membership_key membership
      "membership_#{membership.group_id ||
      membership.changes[:group_id]&.second ||
      membership.changes[:group_id]&.first}"
    end

  end
end
