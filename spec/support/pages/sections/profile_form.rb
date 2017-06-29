require_relative 'membership_panel'

module Pages
  module Sections
    class ProfileForm < SitePrism::Section
      element :given_name, '#person_given_name'
      element :surname, '#person_surname'
      element :email, '#person_email'
      element :save, "input[type=submit][value='Save']"

      # membership errors
      element :team_membership_error_destination_anchor, '#error_person_membership'
      elements :team_required_field_errors, 'div[id^="error_membership_"][id$="_group"]'

      sections :membership_panels, Sections::MembershipPanel, '.membership.panel'
    end
  end
end
