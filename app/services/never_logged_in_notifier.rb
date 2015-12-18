module NeverLoggedInNotifier

  def self.send_reminders
    return unless Rails.configuration.send_reminder_emails

    Person.never_logged_in.each do |person|
      person.with_lock do # use db lock in case cronjob running on two instances
        person.reload
        dont_send = person.reminder_email_sent?(within_days: 30) || person.login_count > 0
        unless dont_send
          ReminderMailer.never_logged_in(person).deliver_later
          person.update(last_reminder_email_at: Time.zone.now)
        end
      end
    end
  end
end
