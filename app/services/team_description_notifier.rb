module TeamDescriptionNotifier
  def self.send_reminders
    return unless Rails.configuration.send_reminder_emails

    Group.without_description.each do |group|
      group.with_lock do # use db lock to allow cronjob to run on more than one instance
        send_reminder group
      end
    end
  end

  def self.send_reminder(group)
    group.reload
    if send_description_reminder? group
      group.leaders.each do |leader|
        ReminderMailer.team_description_missing(leader, group).deliver_later
      end
      group.update(description_reminder_email_at: Time.zone.now) # rubocop:disable Rails/SaveBang
    end
  end

  def self.send_description_reminder?(group)
    !group.description_reminder_email_sent?(within_days: 30)
  end

  private_class_method :send_reminder, :send_description_reminder?
end
