require 'rails_helper'

feature "Group maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Drilling down through groups" do
    department = create(:group, name: "Ministry of Justice")
    org = create(:group, name: "An Organisation", parent: department)
    team = create(:group, name: "A Team", parent: org)
    subteam = create(:group, name: "A Subteam", parent: team)

    visit group_path(department)
    expect(page).to have_text("An Organisation")
    expect(page).not_to have_text("A Team")
    expect(page).not_to have_text("A Subteam")

    click_link "An Organisation"
    expect(page).to have_text("A Team")
    expect(page).not_to have_text("A Subteam")

    click_link "A Team"
    expect(page).to have_text("A Subteam")
  end
end
