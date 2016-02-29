module NeverLoggedInNotifier

  def self.send_reminders
    return unless Rails.configuration.send_reminder_emails

    Person.never_logged_in(2).each do |person|
      person.with_lock do # use db lock in case cronjob running on two instances
        send_reminder person
      end
    end
  end

  def self.send_reminder person
    person.reload
    if person.send_never_logged_in_reminder?
      ReminderMailer.never_logged_in(person).deliver_later
      person.update(last_reminder_email_at: Time.zone.now)
    end
  end

  private_class_method :send_reminder

end
