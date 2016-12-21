class MembershipChangesPresenter < ChangesPresenter

  class ::Hash
    def to_membership_set
      MembershipChangeSet.new(deep_symbolize_keys)
    end
  end

  attr_reader :current_team

  def format raw_change_set
    h = {}
    raw_change_set&.each do |membership_key, raw_changes|
      set_current_team(membership_key)
      h[membership_key] = {}
      membership_template(h[membership_key], raw_changes)
    end
    h.deep_symbolize_keys
  end

  def each_pair
    @changes&.each_pair do |_membership, membership_changes|
      membership_changes.each_pair do |field, change|
        yield field, change[:message]
      end
    end
  end

  private

  def set_current_team membership_key
    @current_team = Group.find(membership_key.to_s.sub('membership_',''))
  end

  def membership_template memo, raw_changes
    set = raw_changes.to_membership_set
    if set.added? || set.removed?
      memo.merge! added_removed_template(set)
    else
      amended_changes(memo, raw_changes)
    end
  end

  def added_removed_template set
    key = set.added? ? :added : :removed
    template(key) do |h|
      h[key][:raw] = set.raw_changes
      h[key][:message] = set.sentence
    end
  end

  def amended_changes memo, raw_changes
    raw_changes.each do |field, raw_change|
      if team_change? field
        memo.merge! team_change(field, raw_change)
      elsif role_change? field
        memo.merge! role_change(field, raw_change)
      elsif leader_change? field
        memo.merge! leader_change(field, raw_changes.deep_symbolize_keys)
      elsif subscribed_change? field
        memo.merge! subscribed_change(field, raw_changes.deep_symbolize_keys)
      else
        memo.merge! default(field, raw_change)
      end
    end
  end

  def leader_change? field
    field.to_sym == :leader
  end

  def leader_change field, raw_changes
    template(field) do |h|
      h[field][:raw] = raw_changes[:leader]
      h[field][:message] = leader_change_sentence(raw_changes[:leader])
    end
  end

  def leader_change_sentence leader_change
    leader = Change.new(leader_change)
    if leader.addition?
      "Made you leader of the #{current_team} team"
    elsif leader.removal?
      "Removed you as leader of the #{current_team} team"
    end
  end

  def subscribed_change? field
    field.to_sym == :subscribed
  end

  def subscribed_change field, raw_changes
    template(field) do |h|
      h[field][:raw] = raw_changes[:subscribed]
      h[field][:message] = subscribed_change_sentence(raw_changes[:subscribed])
    end
  end

  def subscribed_change_sentence subscribed_change
    subscribed = Change.new(subscribed_change)

    if subscribed.addition?
      "Changed your notification settings so you do get notifications if changes are made to the #{current_team} team"
    elsif subscribed.removal?
      "Changed your notification settings so you don't get notifications if changes are made to the #{current_team} team"
    end
  end

  def role_change? field
    field.to_sym == :role
  end

  def role_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = role_change_sentence(raw_change)
    end
  end

  def role_change_sentence raw_change
    change = Change.new(raw_change)
    if change.addition?
      "Added the role #{change.new_val} for #{current_team} team"
    elsif change.removal?
      "Removed the role #{change.old_val} for #{current_team} team"
    elsif change.modification?
      "Changed the role #{change.old_val} to #{change.new_val} for #{current_team} team"
    end
  end

  def team_change? field
    field.to_sym == :group_id
  end

  def team_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = team_change_sentence(raw_change)
    end
  end

  def team_change_sentence raw_change
    change = Change.new(raw_change)
    if change.addition?
      "Added you to the team #{Group.find(change.new_val).name}"
    elsif change.removal?
      "Removed you from the team #{Group.find(change.old_val).name}"
    elsif change.modification?
      "Changed your membership of the team #{Group.find(change.old_val).name} to #{Group.find(change.new_val).name}"
    end
  end
end
