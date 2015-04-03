module Concerns::Notifications
  extend ActiveSupport::Concern

  included do
    def send_create_email!(current_user)
      if should_send_email_notification?(email, current_user)
        UserUpdateMailer.new_profile_email(
          self, current_user.email
        ).deliver_later
      end
    end

    def send_update_email!(current_user)
      if should_send_email_notification?(email, current_user)
        UserUpdateMailer.updated_profile_email(
          self, current_user.email
        ).deliver_later
      end
    end

    def send_destroy_email!(current_user)
      if should_send_email_notification?(email, current_user)
        UserUpdateMailer.deleted_profile_email(
          self, current_user.email
        ).deliver_later
      end
    end

  private

    def should_send_email_notification?(email, current_user)
      EmailAddress.new(email).valid_address? &&
        current_user.email != email
    end
  end
end
