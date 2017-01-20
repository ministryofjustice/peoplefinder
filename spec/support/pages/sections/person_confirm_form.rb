module Pages
  module Sections
    class PersonConfirmForm < SitePrism::Section
      element :given_name_field, '#person_given_name'
      element :surname_field, '#person_surname'
      element :email_field, '#person_email'
      element :continue_button, "input[type='submit'][value='Continue, it is not one of these'][class='button']"
    end
  end
end
