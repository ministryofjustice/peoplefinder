require "rails_helper"

describe "Home page" do
  include PermittedDomainHelper

  let(:home_page) { Pages::Home.new }
  let(:ie8) { "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)" }
  let(:ie7) { "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)" }
  let(:ie6) { "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)" }
  let(:department) { create(:department) }

  before do
    create(:person, :member_of, team: department, leader: true, role: "Permanent Secretary", given_name: "Richard", surname: "Heaton")
  end

  context "with a page structure" do
    before do
      page.driver.header "User-Agent", user_agent
      mock_readonly_user
      visit "/"
    end

    context "when using a supported browser" do
      it "is all there" do
        expect(home_page).to be_displayed
        expect(home_page).to have_page_title
        expect(home_page).to have_about_usage
        expect(home_page).to have_create_profile_link
        expect(home_page).to have_search_form
        expect(home_page).to have_department_overview
      end

      it "has page title" do
        expect(home_page).to have_page_title
        expect(home_page.page_title).to have_text("People Finder")
      end

      it "has about usage section" do
        expect(home_page).to have_about_usage
        expect(home_page.about_usage).to have_text "People Finder relies on contributions from everyone to help keep it up-to-date"
      end

      it "has department overview section" do
        expect(home_page).to have_department_overview
        expect(home_page.department_overview).to have_department_name
        expect(home_page.department_overview).to have_leader_profile_image
        expect(home_page.department_overview).to have_text "About the team"
        expect(home_page.department_overview).to have_text "Teams within #{department}"
      end

      context "with Firefox 31+" do
        it "displays no warning" do
          expect(home_page).to be_displayed
          expect(home_page).not_to have_unsupported_browser_warning
        end
      end

      context "with Internet Explorer 8+" do
        let(:user_agent) { ie8 }

        it "displays no warning" do
          expect(home_page).to be_displayed
          expect(home_page).not_to have_unsupported_browser_warning
        end
      end
    end

    context "when using an unsupported browser" do
      context "with Internet Explorer 6.0" do
        let(:user_agent) { ie6 }

        it "displays a warning" do
          expect(home_page).to be_displayed
          expect(home_page).to have_unsupported_browser_warning
        end
      end

      context "with Internet Explorer 7.0" do
        let(:user_agent) { ie7 }

        it "displays a warning" do
          expect(home_page).to be_displayed
          expect(home_page).to have_unsupported_browser_warning
        end
      end
    end
  end

  context "with a regular user" do
    before do
      token_log_in_as "test.user@digital.justice.gov.uk"
      visit "/"
    end

    it "can view the page" do
      expect(home_page).to be_displayed
    end
  end

  context "with a readonly user" do
    before do
      mock_readonly_user
      visit "/"
    end

    it "can view the page" do
      expect(home_page).to be_displayed
    end
  end
end
