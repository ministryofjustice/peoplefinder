module Pages
  module Sections
    class SearchFiltersForm < SitePrism::Section
      element :people_filter, "input[type='checkbox'][id='people'][value='people']"
      element :teams_filter, "input[type='checkbox'][id='teams'][value='teams']"
    end
  end
end
