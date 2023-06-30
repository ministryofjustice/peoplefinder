require "rails_helper"

describe "Google Analytics tracking" do
  include PermittedDomainHelper

  let(:person) { create :person }
  let(:group) { create :group }

  context "with a token request button" do
    it "has virtual-pageview data to pass GA" do
      visit new_sessions_path(person)
      node = find_button("Request link")
      expect(node["data-virtual-pageview"]).to eql "/sessions/token-request"
    end
  end

  context "with edit profile links" do
    before do
      token_log_in_as "test.user@digital.justice.gov.uk"
      visit person_path(person)
    end

    it "have event data to pass to GA" do
      expect(page.find_all("[data-event-category]").map(&:text)).to include "Edit this profile", "complete this profile"
    end

    it "have virtual-pageview data to pass GA" do
      expect(page.find_all("[data-virtual-pageview]").map(&:text)).to include "Edit this profile", "complete this profile"
    end
  end

  context "with edit team links" do
    before do
      token_log_in_as "test.user@digital.justice.gov.uk"
      visit group_path(group)
    end

    it "have event data to pass to GA" do
      expect(page.find_all("[data-event-category]").map(&:text)).to include "Edit this team"
    end

    it "have virtual-pageview data to pass GA" do
      expect(page.find_all("[data-virtual-pageview]").map(&:text)).to include "Edit this team"
    end
  end
end
