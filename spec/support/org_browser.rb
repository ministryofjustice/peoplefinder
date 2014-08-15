module SpecSupport
  module OrgBrowser
    def click_in_org_browser(text)
      find('.org-browser .actionable', text: text).trigger(:click)
    end
  end
end
