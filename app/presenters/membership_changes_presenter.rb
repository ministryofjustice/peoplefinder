class MembershipChangesPresenter < ChangesPresenter

  class ::Hash
    def to_membership_set
      MembershipChangeSet.new(deep_symbolize_keys)
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
