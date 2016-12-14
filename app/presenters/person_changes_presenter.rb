class PersonChangesPresenter < ChangesPresenter

  def format raw_changes
    h = {}
    raw_changes.each do |field, raw_change|
      next unless changed? raw_change
      if work_days? field
        create_or_add_work_days(h, field, raw_change)
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
end
