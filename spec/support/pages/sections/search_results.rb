module Pages
  module Sections
    class SearchResultSection < SitePrism::Section
      element :name_link, ".details > h3 > a"
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
    end
  end
end
