module Concerns::Notifications
  extend ActiveSupport::Concern

  included do
    def send_destroy_email!(current_user)
      if should_send_email_notification?(current_user)
        UserUpdateMailer.deleted_profile_email(
          self, current_user.email
        ).deliver_later
      end
    end

    def should_send_email_notification?(current_user)
      EmailAddress.new(email).valid_address? &&
        current_user.try(:email) != email
    end
  end
end
