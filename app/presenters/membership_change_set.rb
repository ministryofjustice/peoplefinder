class MembershipChangeSet

  attr_reader :raw_changes

  def initialize raw_changes
    @raw_changes = raw_changes
  end

  def added?
    raw_changes[:group_id].first.nil?
  rescue
    false
  end

  def removed?
    raw_changes[:group_id].second.nil?
  rescue
    false
  end

  def team_name
    group = change(raw_changes[:group_id])
    team = Group.find(group.new_val || group.old_val)
    "the #{team}"
  rescue ActiveRecord::RecordNotFound
    'a no longer existing'
  end

  def team id
    Group.find(id).name
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
    "Added you to #{team_name} team#{role_addendum}.#{leader_addendum}"
  end

  def removed_sentence
    "Removed you from the #{team_name} team"
  end

  private

  # map undefined methods to membership attribute keys
  # to simplify value retrieval.
  # i.e. set.role, set.role?
  def method_missing method_name, *args
    @method_name = method_name
    if valid_missing_method
      if raw_changes.key?(attribute_name_from_method)
        change = change(raw_changes[attribute_name_from_method])
        val = change.new_val || change.old_val
        return val.present? if @method_name.to_s =~ /\?$/
        val
      end
    else
      super
    end
  end

  def valid_missing_method
    valid_methods = Membership.columns.flat_map { |col| [col.name, "#{col.name}?"] }.map(&:to_sym)
    valid_methods.include? @method_name.to_sym
  end

  def attribute_name_from_method
    @method_name.to_s.sub('?', '').to_sym
  end

  def change raw_change
    ChangesPresenter::Change.new(raw_change)
  end
end
