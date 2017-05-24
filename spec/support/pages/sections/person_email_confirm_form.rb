module Pages
  module Sections
    class PersonEmailConfirmForm < SitePrism::Section
      element :email_field, '#person_email'
      element :secondary_email_field, '#person_secondary_email'
      element :continue_button, "input[type='submit'][value='Continue'][class='button']"
    end
  end
end
