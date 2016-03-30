module PersonUpdateNotifier

  def self.send_reminders
    return unless Rails.configuration.send_reminder_emails

    Person.logged_in_at_least_once(25).find_each do |person|
      person.with_lock do # use db lock to allow cronjob to run on more than one instance
        send_reminder person
      end
    end
  end

  def self.send_reminder person
    person.reload
    if send_update_reminder? person
      ReminderMailer.person_profile_update(person).deliver_later
      person.update(last_reminder_email_at: Time.zone.now)
    end
  end

  def self.send_update_reminder? person
    if person.login_count == 0
      false
    else
      !person.reminder_email_sent?(within: 6.months) &&
        person.updated_at.end_of_day < 6.months.ago
    end
  end

  private_class_method :send_reminder

end
