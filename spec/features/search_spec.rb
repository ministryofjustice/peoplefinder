require "rails_helper"

describe "Searching feature", :opensearch do
  extend FeatureFlagSpecHelper

  def create_test_data
    PermittedDomain.find_or_create_by!(domain: "digital.justice.gov.uk")
    group = create(:group, name: "HMP Wilsden")
    create(
      :person,
      :member_of, team: group, sole_membership: true,
                  given_name: "Jon",
                  surname: "Browne",
                  email: "jon.browne@digital.justice.gov.uk",
                  primary_phone_number: "0711111111",
                  current_project: "Digital Prisons"
    )
    create(
      :person,
      given_name: "Dodgy<script> alert('XSS'); </script>",
      surname: "Bloke",
      email: "dodgy.bloke@digital.justice.gov.uk",
      primary_phone_number: "0711111111",
      current_project: "Digital Prisons",
    )
  end

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    clean_up_indexes_and_tables
    create_test_data
    Person.import force: true
    Person.__opensearch__.refresh_index!
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    clean_up_indexes_and_tables
  end

  before do
    token_log_in_as "test.user@digital.justice.gov.uk"
    visit home_path
  end

  it "does not error on null search" do
    click_button "Search"
    expect(page).to have_content("not found")
  end

  describe "for people" do
    it "retrieves single exact match for email" do
      fill_in "query", with: "jon.browne@digital.justice.gov.uk"
      click_button "Search"
      expect(page).to have_selector(".cb-person", count: 1)
    end

    it "retrieves the details of matching people" do
      fill_in "query", with: "Browne"
      click_button "Search"
      expect(page).to have_title("Search results - #{app_title}")
      within(".breadcrumbs ol") do
        expect(page).to have_text("Search results")
      end
      within(".cb-search-result-summary") do
        expect(page).to have_text(/\d+ result(s)?/)
      end
      within(".mod-search-form") do
        expect(page).to have_selector("input[value='Browne']")
      end
      expect(page).to have_text("Jon Browne")
      expect(page).to have_text("jon.browne@digital.justice.gov.uk")
      expect(page).to have_text("0711111111")
      expect(page).to have_text("Digital Prisons")
      expect(page).to have_link("add them", href: new_person_path)
    end
  end

  describe "for groups" do
    it "retrieves the details of the matching group and people in that group" do
      fill_in "query", with: "HMP Wilsden"
      click_button "Search"
      expect(page).to have_selector(".cb-group-name", text: "HMP Wilsden")
      expect(page).to have_selector(".cb-person-name", text: "Jon Browne")
    end
  end

  describe "higlighting of search terms" do
    it "highlights entire matching email address" do
      fill_in "query", with: "jon.browne@digital.justice.gov.uk"
      click_button "Search"
      within ".cb-person-email" do
        expect(page).to have_selector(".es-highlight", text: "jon.browne@digital.justice.gov.uk")
      end
    end

    it "highlights individual role and group terms" do
      fill_in "query", with: "HMP Wilsden"
      click_button "Search"
      within ".cb-person-memberships" do
        expect(page).to have_selector(".es-highlight", text: "HMP")
        expect(page).to have_selector(".es-highlight", text: "Wilsden")
      end
    end

    it "highlights individual name terms" do
      fill_in "query", with: "Jon Browne"
      click_button "Search"
      within "#person-results" do
        expect(page).to have_selector(".es-highlight", text: "Browne")
        expect(page).to have_selector(".es-highlight", text: "Jon")
      end
    end

    it "highlights individual current project terms" do
      fill_in "query", with: "Digital Prisons Browne"
      click_button "Search"
      within ".cb-person-current-project", match: :first do
        expect(page).to have_selector(".es-highlight", text: "Digital")
        expect(page).to have_selector(".es-highlight", text: "Prisons")
      end
    end

    it "does not highlight unsanitary attribute values" do
      fill_in "query", with: "dodgy bloke"
      click_button "Search"
      within ".cb-person-name" do
        expect(page).not_to have_selector(".es-highlight")
        expect(page).to have_text("Dodgy<script> alert('XSS'); </script> Bloke")
      end
    end
  end
end
