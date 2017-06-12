module Pages
  module Sections
    class PersonResult < SitePrism::Section
      element :name_link, '.cb-person-name > a'
    end

    class TeamResult < SitePrism::Section
      element :name_link, '.cb-group-name > a'
    end

    class SearchResults < SitePrism::Section
      sections :people_results, PersonResult, '.cb-person'
      sections :team_results, TeamResult, '.cb-group'

      def people_result_name_links
        people_results.map { |pr| pr.name_link['href'] }
      end

      def people_result_names
        people_results.map { |pr| pr.name_link.text }
      end

      def team_result_name_links
        team_results.map { |tr| tr.name_link['href'] }
      end

      def team_result_names
        team_results.map { |tr| tr.name_link.text }
      end
    end
  end
end
