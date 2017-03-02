class ProfileChangeAggregator

  # takes a grouped queue notification record (produced by QueuedNotification.unsent_groups)
  def initialize(notifications)
    @notifications = notifications
  end

  # this method takes the raw changes from the records in turn and produces
  # one set of changes detailing the original values and the final values of
  # each changed field
  def aggregate_raw_changes
    full_change_set = {}
    @notifications.each do |rec|
      record_raw_changes = extract_raw_changes(rec)
      new_change_set = merge_changes(full_change_set, record_raw_changes)
      full_change_set = new_change_set
    end
    eliminate_noops(full_change_set)
  end

  private

  def merge_changes(existing_changes, new_changes)
    new_changes.each do |field, change_set|
      if membership_field?(field)
        update_membership(existing_changes, field, change_set)
      else
        update_non_membership_field(existing_changes, field, change_set)
      end
    end
    existing_changes
  end

  def update_non_membership_field(existing_changes, field, change_set)
    if existing_changes.key?(field)
      update_change_set(existing_changes, field, change_set)
    else
      insert_change_set(existing_changes, field, change_set)
    end
  end

  def update_membership(existing_changes, field, change_set)
    if existing_changes.key?(field)
      merge_membership_changes(existing_changes, field, change_set)
    else
      insert_change_set(existing_changes, field, change_set)
    end
  end

  # removes any fields from the change set where the starting value is identical to the ending value
  def eliminate_noops(changes)
    copy_changes = {}
    changes.each do |field, changeset|
      if membership_field?(field)
        copy_changes[field] = eliminate_noops(changes[field])
      else
        next if no_change?(changeset)
        copy_changes[field] = changes[field]
      end
    end
    copy_changes
  end

  def no_change?(changeset)
    (changeset.first == '' && changeset.last.nil?) ||
      (changeset.first.nil? && changeset.last == '') ||
      (changeset.first == changeset.last)
  end

  def extract_raw_changes(rec)
    rec.changes_hash['data']['raw']
  end

  # A change set for this field already exists in @raw changes, so we leave
  # the original value as it is, and update the new value
  def update_change_set(existing_changes, field, change_set)
    existing_changes[field] = case membership_field?(field)
                              when true
                                merge_membership_changes(existing_changes[field], change_set)
                              when false
                                [existing_changes[field].first, change_set.last]
                              end
  end

  # insert a new change_set into @raw_changes
  def insert_change_set(existing_changes, field, change_set)
    existing_changes[field] = change_set
  end

  def not_membership_field?(field)
    !membership_field?(field)
  end

  def membership_field?(field)
    !!(field.to_s =~ /^membership_\d{1,6}$/)
  end

  def merge_membership_changes(existing_changes, field, change_set)
    merged_changes = merge_changes(existing_changes[field], change_set)
    existing_changes[field] = merged_changes
  end
end
