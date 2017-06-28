module SpecSupport
  module OrgBrowser

    def last_membership
      all('#memberships .membership').last
    end

    def select_in_parent_team_select(text)
      within '.root-node.team' do
        click_link text
      end
    end

    def select_in_team_select(text)
      within last_membership do
        click_link text
      end
    end

    def leader_question
      within last_membership do
        find('.team-leader fieldset legend').text
      end
    end

    def click_on_team_in_org_browser(text)
      find('.org-browser .team-link', text: text).trigger(:click)
    end

    def click_on_subteam_in_org_browser(text)
      find('.org-browser .subteam-link', text: text).trigger(:click)
    end
  end
end
