module PersonUpdateNotifier

  def self.send_reminders within: 6.months
    return unless Rails.configuration.send_reminder_emails

    people_to_remind(within).each do |person|
      person.with_lock do # use db lock to allow cronjob to run on more than one instance
        send_reminder person, within
      end
    end
  end

  def self.people_to_remind within
    Person.
      logged_in_at_least_once.
      last_reminder_email_older_than(within.ago).
      updated_at_older_than(within.ago)
  end

  def self.send_reminder person, within
    person.reload
    if send_update_reminder? person, within
      ReminderMailer.person_profile_update(person).deliver_later
      person.update(last_reminder_email_at: Time.zone.now)
    end
  end

  def self.send_update_reminder? person, within
    if person.login_count == 0
      false
    else
      !person.reminder_email_sent?(within: within) &&
        person.updated_at.end_of_day < within.ago
    end
  end

  private_class_method :send_reminder

end
