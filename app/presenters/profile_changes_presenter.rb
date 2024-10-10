class ProfileChangesPresenter < ChangesPresenter
  def format(raw_changes)
    split_presenters raw_changes
  end

  def each(&block)
    @changes.each do |presenter|
      presenter.each_value(&block)
    end
  end

  def each_pair(&block)
    @changes.each do |presenter|
      presenter.each_pair(&block)
    end
  end

  def all_messages
    messages = []
    each_pair { |_, b| messages << b }
    messages
  end

private

  MEMBERSHIP_KEY_PATTERN = /membership_.*/

  def split_presenters(raw_changes)
    [
      PersonChangesPresenter.new(raw_person_changes(raw_changes)),
      MembershipChangesPresenter.new(raw_membership_changes(raw_changes)),
    ]
  end

  def raw_membership_changes(raw_changes)
    raw_changes.select { |k, _v| MEMBERSHIP_KEY_PATTERN.match(k) }
  end

  def raw_person_changes(raw_changes)
    raw_changes.reject { |k, _v| MEMBERSHIP_KEY_PATTERN.match(k) }
  end
end
