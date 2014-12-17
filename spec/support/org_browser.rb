module SpecSupport
  module OrgBrowser
    def click_on_team_in_org_browser(text)
      find('.new-org-browser .team-link', text: text).trigger(:click)
    end

    def click_on_subteam_in_org_browser(text)
      find('.new-org-browser .subteam-link', text: text).trigger(:click)
    end
  end
end
