module Pages
  module Sections
    class ProfileForm < SitePrism::Section
      element :global_error, '.alert.alert-error'

      element :surname, '#person_surname'
      element :surname_error, :xpath, '//label[@for="person_surname"]/*[@class="error"]'

      element :email, '#person_email'
      element :email_error, :xpath, '//label[@for="person_email"]/*[@class="error"]'

      element :save, 'input[type=submit]'
    end
  end
end
