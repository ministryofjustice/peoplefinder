module NeverLoggedInNotifier

  def self.send_reminders
    Person.never_logged_in.each do |person|
      unless person.reminder_email_sent?(within_days: 30)
        ReminderMailer.never_logged_in(person).deliver_later
      end
    end
  end
end
