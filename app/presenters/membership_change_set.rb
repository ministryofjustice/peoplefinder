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
    team = change(raw_changes[:group_id])
    Group.find(team.new_val || team.old_val).name
  end

  def sentence
    if added?
      added_sentence
    elsif removed?
      removed_sentence
    end
  end

  def added_sentence
    role_addendum = " as #{role}" if role?
    leader_addendum = ' You are a leader of the team.' if leader?
    "Added you to the #{team_name} team#{role_addendum}.#{leader_addendum}"
  end

  def removed_sentence
    "Removed you from the #{team_name} team"
  end

  private

  # map undefined methods to membership attribute keys
  # to simplify value retrieval.
  # i.e. set.role, set.role?
  def method_missing name, *args
    @name = name
    if valid_missing_method
      if raw_changes.key?(attribute_name_from_method)
        change = change(raw_changes[attribute_name_from_method])
        val = change.new_val || change.old_val
        return val.present? if @name.to_s =~ /\?$/
        val
      end
    else
      super
    end
  end

  def valid_missing_method
    valid_methods = Membership.columns.flat_map { |col| [col.name, "#{col.name}?"] }.map(&:to_sym)
    valid_methods.include? @name.to_sym
  end

  def attribute_name_from_method
    @name.to_s.sub('?', '').to_sym
  end

  def change raw_change
    ChangesPresenter::Change.new(raw_change)
  end
end
