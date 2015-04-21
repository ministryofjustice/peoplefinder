module Concerns::Notifications
  extend ActiveSupport::Concern

  included do
    def should_send_email_notification?(current_user)
      EmailAddress.new(email).valid_address? &&
        current_user.try(:email) != email
    end
  end
end
