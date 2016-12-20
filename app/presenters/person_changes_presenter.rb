class PersonChangesPresenter < ChangesPresenter

  WORK_DAYS_FIELD = 'work_days'.freeze

  def format raw_changes
    raw_changes.inject({}) do |memo, (field, raw_change)|
      next memo unless changed? raw_change
      if work_days? field
        add_or_create_work_days(memo, field, raw_change)
      elsif profile_photo? field
        memo.merge! profile_photo_change(field, raw_change)
      elsif extra_info? field
        memo.merge! extra_info_change(field, raw_change)
      else
        memo.merge! default(field, raw_change)
      end
    end.deep_symbolize_keys
  end

  private

  def work_days? field
    field.to_s =~ /^works_.*$/
  end

  def add_or_create_work_days memo, field, raw_change
    if memo.key? WORK_DAYS_FIELD
      memo[WORK_DAYS_FIELD][:raw][field] = raw_change
      memo
    else
      memo.merge! work_days_template(field, raw_change)
    end
  end

  def work_days_template field, raw_change
    template(WORK_DAYS_FIELD) do |h|
      h[WORK_DAYS_FIELD][:raw] ||= {}
      h[WORK_DAYS_FIELD][:raw][field] = raw_change
      h[WORK_DAYS_FIELD][:message] ||= 'Changed your working days'
    end
  end

  def profile_photo? field
    field.to_sym == :profile_photo_id
  end

  def profile_photo_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = profile_photo_sentence(field, raw_change)&.humanize
    end
  end

  def profile_photo_sentence field, raw_change
    change = Change.new(raw_change)
    if change.addition?
      "added a #{field}"
    elsif change.removal?
      "removed the #{field}"
    elsif change.modification?
      "changed your #{field}"
    end
  end

  def extra_info? field
    field.to_sym == :description
  end

  def extra_info_change field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = extra_info_sentence(field, raw_change)&.humanize
    end
  end

  def extra_info_sentence _field, raw_change
    change = Change.new(raw_change)
    term = 'extra information'
    if change.addition?
      "added #{term}"
    elsif change.removal?
      "removed #{term}"
    elsif change.modification?
      "changed your #{term}"
    end
  end

end
