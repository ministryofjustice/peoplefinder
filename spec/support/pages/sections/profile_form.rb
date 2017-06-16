module Pages
  module Sections
    class ProfileForm < SitePrism::Section
      element :given_name, '#person_given_name'
      element :surname, '#person_surname'
      element :email, '#person_email'
      element :save, "input[type=submit][value='Save']"
     end
  end
end
