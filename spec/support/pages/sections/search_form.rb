module Pages
  module Sections
    class SearchForm < SitePrism::Section
      element :search_field, "input[type='search'][id='mod-search-input']"
      element :search_button, "input[type='submit'][value='Search'][class='mod-search-submit']"
    end
  end
end
