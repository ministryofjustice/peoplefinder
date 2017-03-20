module Pages
  module Sections
    class SearchForm < SitePrism::Section
      element :search_field, "input[type='text'][id='query']"
      element :search_button, "input[type='submit'][value='Submit search'][class='button']"
    end
  end
end
