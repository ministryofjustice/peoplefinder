# This class is instantiated regularly by the whenever gem
# to examine the QueuedNotifications table for outstanding
# notifications, and batch them together and mail to users.
#

class NotificationSender

  def initialize
    @grouped_items = QueuedNotification.unsent_groups
  end

  def send!
    @grouped_items.each { |gi| process_group(gi) }
  end

  # private

  def process_group(gi)
    notifications = QueuedNotification.start_processing_grouped_item(gi)
    unless notifications.nil?
      @person = notifications.first.person
      @logged_in_user = notifications.first.current_user
      if new_profile_notification?(notifications)
        send_new_profile_mail
      else
        send_updated_profile_mail(notifications)
      end
      notifications.update_all(sent: true)
    end
  end

  def new_profile_notification?(notifications)
    notifications.map(&:email_template).include?('new_profile_email')
  end

  def send_new_profile_mail
    UserUpdateMailer.new_profile_email(@person, @logged_in_user.try(:email)).deliver_later
  end

  def send_updated_profile_mail(notifications)
    aggregator = ProfileChangeAggregator.new(notifications)
    changes_presenter = ProfileChangesPresenter.new(aggregator.aggregate_raw_changes)
    UserUpdateMailer.updated_profile_email(@person,
      changes_presenter.serialize,
      @logged_in_user.try(:email)).deliver_later
  end

end
