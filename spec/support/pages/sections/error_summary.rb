module Pages
  module Sections
    class ErrorSummary < SitePrism::Section
      # person errors
      element :given_name_error, "a[href='#error_person_given_name']"
      element :surname_error, "a[href='#error_person_surname']"
      element :email_error, "a[href='#error_person_email']"

      # membership errors
      element :team_required_error, "a[href^='#error_membership_'][href$='_group']"
      element :team_membership_required_error, "a[href='#error_person_membership']"
    end
  end
end
