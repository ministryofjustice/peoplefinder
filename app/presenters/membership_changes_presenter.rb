class MembershipChangesPresenter < ChangesPresenter

  SENTENCE_EXCEPTIONS = %w(group_id role leader subscribed).freeze

  class ::Hash
    def to_membership_set
      MembershipChangeSet.new(deep_symbolize_keys)
    end
  end

  def format raw_change_set
    h = {}
    raw_change_set&.each do |membership_key, raw_changes|
      self.current_team = membership_key
      h[membership_key] = {}
      membership_template(h[membership_key], raw_changes)
    end
    h.deep_symbolize_keys
  end

  def each
    @changes.each do |membership|
      membership.each do |change|
        yield change
      end
    end
  end

  def each_pair
    @changes&.each_pair do |_membership, membership_changes|
      membership_changes.each_pair do |field, change|
        yield field, change[:message]
      end
    end
  end

  private

  attr_reader :current_team

  def current_team=(membership_key)
    @current_team = Group.find(membership_key.to_s.sub('membership_', ''))
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
      if bespoke_rule? field
        memo.merge! send("#{field}_change".to_sym, field, raw_change)
      else
        memo.merge! default(field, raw_change)
      end
    end
  end

  def bespoke_rule? field
    SENTENCE_EXCEPTIONS.include? field.to_s
  end

  def leader_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = leader_change_sentence(raw_change)
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

  def subscribed_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = subscribed_change_sentence(raw_change)
    end
  end

  def subscribed_change_sentence subscribed_change
    subscribed = Change.new(subscribed_change)
    subscribed_text(subscribed.addition?)
  end

  def subscribed_text subscribed
    'Changed your notification settings so you ' \
      "#{subscribed ? 'do' : 'don\'t'}" \
      " get notifications if changes are made to the #{current_team} team"
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
      "Added the role #{change.new_val} in the #{current_team} team"
    elsif change.removal?
      "Removed the role #{change.old_val} in the #{current_team} team"
    elsif change.modification?
      "Changed your role from #{change.old_val} to #{change.new_val} in the #{current_team} team"
    end
  end

  def group_id_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = team_change_sentence(raw_change)
    end
  end

  def team_change_sentence raw_change
    change = Change.new(raw_change)
    if change.addition?
      "Added you to the #{Group.find(change.new_val).name} team"
    elsif change.removal?
      "Removed you from the #{Group.find(change.old_val).name} team"
    elsif change.modification?
      "Changed your membership of the #{Group.find(change.old_val).name} team \
      to the #{Group.find(change.new_val).name} team"
    end
  end
end
