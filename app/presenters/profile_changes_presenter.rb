class ProfileChangesPresenter < ChangesPresenter

  def format raw_changes
    split_presenters raw_changes
  end

  def each
    @changes.each do |presenter|
      presenter.each do |_field, change|
        yield change
      end
    end
  end

  def each_pair
    @changes.each do |presenter|
      presenter.each_pair do |field, message|
        yield field, message
      end
    end
  end

  private

  MEMBERSHIP_KEY_PATTERN = /membership_.*/

  def split_presenters raw_changes
    [
      PersonChangesPresenter.new(raw_person_changes(raw_changes)),
      MembershipChangesPresenter.new(raw_membership_changes(raw_changes))
    ]
  end

  def raw_membership_changes raw_changes
    raw_changes.select { |k, _v| MEMBERSHIP_KEY_PATTERN.match(k) }
  end

  def raw_person_changes raw_changes
    raw_changes.select { |k, _v| !MEMBERSHIP_KEY_PATTERN.match(k) }
  end

end
