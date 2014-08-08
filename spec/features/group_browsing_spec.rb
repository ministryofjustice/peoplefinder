require 'rails_helper'

feature "Group browsing" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  let!(:department) { create(:group, name: "Ministry of Justice") }
  let!(:team) { create(:group, name: "A Team", parent: department) }
  let!(:subteam) { create(:group, name: "A Subteam", parent: team) }
  let!(:leaf_node) { create(:group, name: "A Leaf Node", parent: subteam) }

  scenario "Drilling down through groups" do
    visit group_path(department)

    expect(page).to have_link("A Team")
    expect(page).not_to have_link("A Subteam")

    click_link "A Team"
    expect(page).to have_link("A Subteam")
    expect(page).not_to have_link("A Leaf Node")

    click_link "A Subteam"
    expect(page).to have_link("A Leaf Node")
  end

  scenario "A team with subteams" do
    current_group = team
    add_people_to_group(names, current_group)
    visit group_path(current_group)

    expect(page).to have_text("Teams within #{ current_group.name }")
    expect(page).to have_link("View all people in #{ current_group.name }")
  end

  scenario "A team with no subteams (leaf_node) and some people" do
    current_group = leaf_node
    add_people_to_group(names, current_group)
    visit group_path(current_group)

    expect(page).not_to have_text("Teams within #{ current_group.name }")
    expect(page).to have_text("People in #{ current_group.name }")
    names.each do |name|
      expect(page).to have_text(name.join(' '))
    end
  end

  scenario "A team with no subteams (leaf_node) and no people" do
    current_group = leaf_node
    visit group_path(leaf_node)

    expect(page).not_to have_text("Teams within #{ current_group.name }")
    expect(page).not_to have_link("View all people in #{ current_group.name }")
  end

  scenario "Following the view all people link" do
    current_group = team
    add_people_to_group(names, current_group)
    visit group_path(current_group)
    click_link("View all people in #{ current_group.name }")

    within('.breadcrumbs') do
      expect(page).to have_link(current_group.name)
      expect(page).to have_text('All people')
    end

    expect(page).to have_text("People in #{ current_group.name }")
    names.each do |name|
      expect(page).to have_link(name.join(' '))
    end
  end
end

def add_people_to_group(names, group)
  names.each do |gn, sn|
    person = create(:person, given_name: gn, surname: sn)
    create(:membership, person: person, group: group)
  end
end

def names
  [
    %w[ Johnny Cash ],
    %w[ Dolly Parton ],
    %w[ Merle Haggard ]
  ]
end
