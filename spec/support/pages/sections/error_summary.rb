module Pages
  module Sections
    class ErrorSummary < SitePrism::Section

      # person errors
      element :given_name_error, "a[href='#error_person_given_name']"
      element :surname_error, "a[href='#error_person_surname']"
      element :email_error, "a[href='#error_person_email']"

      # group errors (as needed)
    end
  end
end
