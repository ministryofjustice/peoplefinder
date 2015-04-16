module Pages
  module Sections
    class ProfileForm < SitePrism::Section
      element :global_error, '.alert.alert-error'

      element :given_name, '#person_given_name'
      element :given_name_error, :xpath, '//label[@for="person_given_name"]/*[@class="error"]'

      element :surname, '#person_surname'
      element :surname_error, :xpath, '//label[@for="person_surname"]/*[@class="error"]'

      element :email, '#person_email'
      element :email_error, :xpath, '//label[@for="person_email"]/*[@class="error"]'

      element :save, 'input[type=submit][name!=preview]'
    end
  end
end
