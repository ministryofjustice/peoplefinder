class MembershipChangesPresenter < ChangesPresenter

  class ::Hash
    def to_membership_set
      MembershipChangeSet.new(deep_symbolize_keys)
    end
  end

  class MembershipChangeSet

    attr_reader :raw_changes

    def initialize raw_changes
      @raw_changes = raw_changes
    end

    def added?
      raw_changes[:group_id].first.nil?
    end

    def removed?
      raw_changes[:group_id].second.nil?
    end

    def team_name
      change = ChangesPresenter::Change.new(raw_changes[:group_id])
      Group.find(change.new_val || change.old_val).name
    end

    def sentence
      if added?
        added_sentence
      elsif removed?
        removed_sentence
      else
        raise 'Membership Amended detection! Still needs handling'
      end
    end

    def added_sentence
      role_addendum = " as #{role}" if role.present?
      leader_addendum = ' You are a leader of the team.' if leader.present?
      "Added you to the #{team_name} team#{role_addendum}.#{leader_addendum}"
    end

    def removed_sentence
      "Removed you from the #{team_name} team"
    end

    def method_missing name, *args
      if Membership.columns.map(&:name).include?(name.to_s)
        if raw_changes.key?(name.to_sym)
          change = ChangesPresenter::Change.new(raw_changes[name.to_sym])
          change.new_val || change.old_val
        end
      else
        super
      end
    end
  end

  def format raw_change_set
    h = {}
    raw_change_set&.each do |membership, raw_changes|
      h[membership] = {}
      h[membership].merge! membership_template(raw_changes)
    end
    h.deep_symbolize_keys
  end

  def each_pair
    @changes&.each_pair do |_membership, record_changes|
      record_changes.each_pair do |field, change|
        yield field, change[:message]
      end
    end
  end

  private

  def membership_template raw_changes
    set = raw_changes.to_membership_set
    key = set.added? ? :added : :removed
    template(key) do |h|
      h[key][:raw] = set.raw_changes
      h[key][:message] = set.sentence
    end
  end

end
