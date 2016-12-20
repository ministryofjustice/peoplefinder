class PersonChangesPresenter < ChangesPresenter

  def format raw_changes
    h = {}
    raw_changes.each do |field, raw_change|
      next unless changed? raw_change
      if work_days? field
        create_or_add_work_days(h, field, raw_change)
      elsif profile_photo? field
        h.merge! profile_photo_change(field, raw_change)
      elsif extra_info? field
        h.merge! extra_info_change(field, raw_change)
      else
        h.merge! default(field, raw_change)
      end
    end
    h.deep_symbolize_keys
  end

  private

  def work_days? field
    field.to_s =~ /^works_.*$/
  end

  def create_or_add_work_days changes_hash, field, raw_change
    work_days_field = 'work_days'

    if changes_hash.key? work_days_field
      changes_hash[work_days_field][:raw][field] = raw_change
    else
      changes_hash.merge!(
        template(work_days_field) do |h|
          h[work_days_field][:raw] ||= {}
          h[work_days_field][:raw][field] = raw_change
          h[work_days_field][:message] ||= 'Changed your working days'
        end
      )
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
