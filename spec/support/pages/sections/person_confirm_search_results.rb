module Pages
  module Sections
    class PersonConfirmSearchResultSection < SitePrism::Section
      element :name_link, ".cb-person-name > a"
      element :select_button, ".cb-confirmation-select"
    end
  end
end

module Pages
  module Sections
    class PersonConfirmSearchResults < SitePrism::Section
      sections :confirmation_results, Sections::PersonConfirmSearchResultSection, '.cb-confirm-search-result'

      def name_links
        confirmation_results.map do |sr|
          sr.name_link['href']
        end
      end

      def select_buttons
        confirmation_results.map(&:select_button)
      end
    end
  end
end
