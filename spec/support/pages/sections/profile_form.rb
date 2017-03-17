module Pages
  module Sections
    class ProfileForm < SitePrism::Section
      element :global_error, '.alert.alert-error'

      element :given_name, '#person_given_name'
      # element :given_name_error, :xpath, '//label[@for="person_given_name"]/*[@class="error"]'
      element :given_name_error, "a[href='#error_person_given_name']"

      element :surname, '#person_surname'
      # element :surname_error, :xpath, '//label[@for="person_surname"]/*[@class="error"]'
      element :surname_error, "a[href='#error_person_surname']"

      element :email, '#person_email'
      element :email_error, "a[href='#error_person_email']"

      element :save, "input[type=submit][value='Save']"
    end
  end
end
