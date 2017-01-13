module Pages
  module Sections
    class SearchResultSection < SitePrism::Section
      element :name_link, ".details > h3 > a"
      element :select_button, "input[type='submit'][value='Select']"
    end
  end
end

module Pages
  module Sections
    class SearchResults < SitePrism::Section
      sections :search_results, Sections::SearchResultSection, '.search-result'

      def name_links
        search_results.map do |sr|
          sr.name_link['href']
        end
      end

      def select_buttons
        search_results.map(&:select_button)
      end
    end
  end
end
