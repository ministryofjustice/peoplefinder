module NeverLoggedInNotifier

  def self.send_reminders
    return unless Rails.configuration.send_reminder_emails

    Person.never_logged_in(25).find_each do |person|
      person.with_lock do # use db lock to allow cronjob to run on more than one instance
        send_reminder person
      end
    end
  end

  def self.send_reminder person
    person.reload
    if NeverLoggedInNotifier.send_never_logged_in_reminder? person
      ReminderMailer.never_logged_in(person).deliver_later
      person.update(last_reminder_email_at: Time.zone.now)
    end
  end

  def self.send_never_logged_in_reminder? person
    within = 30.days
    !person.reminder_email_sent?(within: within) &&
      person.login_count == 0 &&
      person.created_at.end_of_day < within.ago
  end

  private_class_method :send_reminder

end
