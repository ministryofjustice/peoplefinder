require "rails_helper"

describe "Report a problem", js: true do
  include ActiveJobHelper
  include PermittedDomainHelper

  before(:all) { Timecop.travel(Time.zone.at(1_410_298_020)) }

  after(:all) { Timecop.return }

  before do
    ActionMailer::Base.deliveries.clear
  end

  context "when logged in" do
    let(:me) { create(:person) }
    let(:group) { create(:group) }

    before do
      token_log_in_as(me.email)
    end

    it "Reporting a problem", js: true do
      visit group_path(group)

      click_link "Report a problem" # includes a wait, which is required for the slideToggle jquery behaviour
      fill_in "What were you trying to do?", with: "Rhubarb"
      fill_in "What went wrong?", with: "Custard"

      expect(page).to have_current_path group_path(group), ignore_query: true
    end
  end

  context "when not logged in" do
    it "does not show the feedback form" do
      visit new_sessions_path
      expect(page).not_to have_selector("#feedback_container")
    end
  end
end
