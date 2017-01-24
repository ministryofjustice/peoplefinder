class ReminderMailOlderThanQuery

  class << self
    delegate :call, to: :new
  end

  def initialize(within, relation = Person.all)
    @relation = relation
    @within = within
  end

  def call
    @relation.where('last_reminder_email_at IS NULL OR last_reminder_email_at < ?', @within)
  end
end
