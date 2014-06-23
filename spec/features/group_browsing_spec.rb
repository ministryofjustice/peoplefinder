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

  scenario "Listing team members" do
    department = create(:group, name: "Ministry of Justice")
    org = create(:group, name: "An Organisation", parent: department)
    team = create(:group, name: "A Team", parent: org)

    names = [
      %w[Johnny Cash],
      %w[Dolly Parton],
      %w[Merle Haggard],
    ]

    names.each do |gn, sn|
      person = create(:person, given_name: gn, surname: sn)
      membership = create(:membership, person: person, group: team)
    end

    visit group_path(team)
    names.each do |name|
      expect(page).to have_text(name.join(' '))
    end
  end
end
