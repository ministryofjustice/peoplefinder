class ReminderMailOlderThanQuery < BaseQuery
  def initialize(within, relation = Person.all) # rubocop:disable Lint/MissingSuper
    @relation = relation.ordered_by_name
    @within = within
  end

  def call
    @relation.where("last_reminder_email_at IS NULL OR last_reminder_email_at < ?", @within)
  end
end
