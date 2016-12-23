class PersonAllChangesPresenter < ChangesPresenter

  def format raw_changes
    split(raw_changes)
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

  def split raw_changes
    raw_membership_changes = raw_changes.select { |k, _v| k.to_s =~ /membership_.*/ }
    raw_person_changes = raw_changes.select { |k, _v| !(k.to_s =~ /membership_.*/) }

    person_changes_presenter = PersonChangesPresenter.new(raw_person_changes)
    membership_changes_presenter = MembershipChangesPresenter.new(raw_membership_changes)
    yield person_changes_presenter, membership_changes_presenter if block_given?
    [person_changes_presenter, membership_changes_presenter]
  end
end
