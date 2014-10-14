require 'peoplefinder'

module Peoplefinder::Concerns::Notifications
  extend ActiveSupport::Concern

  included do
    def send_create_email!(current_user)
      if should_send_email_notification?(email, current_user)
        Peoplefinder::UserUpdateMailer.new_profile_email(
          self, current_user.email
        ).deliver
      end
    end

    def send_update_email!(current_user, old_email)
      if email == old_email
        notify_updates_to_unchanged_email_address current_user
      else
        notify_updates_to_changed_email_address current_user, old_email
      end
    end

    def notify_updates_to_unchanged_email_address(current_user)
      if should_send_email_notification?(email, current_user)
        Peoplefinder::UserUpdateMailer.updated_profile_email(
          self, current_user.email
        ).deliver
      end
    end

    def notify_updates_to_changed_email_address(current_user, old_email)
      if should_send_email_notification?(email, current_user)
        Peoplefinder::UserUpdateMailer.updated_address_to_email(
          self, current_user.email, old_email
        ).deliver
      end
      if should_send_email_notification?(old_email, current_user)
        Peoplefinder::UserUpdateMailer.updated_address_from_email(
          self, current_user.email, old_email
        ).deliver
      end
    end

    def send_destroy_email!(current_user)
      if should_send_email_notification?(email, current_user)
        Peoplefinder::UserUpdateMailer.deleted_profile_email(
          self, current_user.email
        ).deliver
      end
    end

  private

    def should_send_email_notification?(email, current_user)
      Peoplefinder::EmailAddress.new(email).valid_address? &&
        current_user.email != email
    end
  end
end
