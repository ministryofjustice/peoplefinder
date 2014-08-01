require 'rails_helper'

feature "Group browsing" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  let!(:department) { create(:group, name: "Ministry of Justice") }
  let!(:org) { create(:group, name: "An Organisation", parent: department) }
  let!(:team) { create(:group, name: "A Team", parent: org) }
  let!(:leaf_node) { create(:group, name: "A Leaf Node", parent: team) }

  scenario "Drilling down through groups" do
    visit group_path(department)

    expect(page).to have_link("An Organisation")
    expect(page).not_to have_link("A Team")
    expect(page).not_to have_link("A Subteam")

    click_link "An Organisation"
    expect(page).to have_link("A Team")
    expect(page).not_to have_link("A Leaf Node")

    click_link "A Team"
    expect(page).to have_link("A Leaf Node")
  end

  scenario "An organisation with subteams and some people" do
    current_group = org
    add_people_to_group(names, current_group)
    visit group_path(current_group)

    expect(page).to have_text("Teams within #{ current_group.name }")
    expect(page).to have_link("View all people in #{ current_group.name }")
  end

  scenario "An organisation with subteams and no people" do
    current_group = org
    visit group_path(current_group)

    expect(page).to have_text("Teams within #{ current_group.name }")
    expect(page).not_to have_link("View all people in #{ current_group.name }")
  end

  scenario "An organisation with no subteams (leaf_node) and some people" do
    current_group = leaf_node
    add_people_to_group(names, current_group)
    visit group_path(current_group)

    expect(page).not_to have_text("Teams within #{ current_group.name }")
    expect(page).to have_text("People in #{ current_group.name }")
    names.each do |name|
      expect(page).to have_text(name.join(' '))
    end
  end

  scenario "An organisation with no subteams (leaf_node) and no people" do
    current_group = leaf_node
    visit group_path(leaf_node)

    expect(page).not_to have_text("Teams within #{ current_group.name }")
    expect(page).not_to have_link("View all people in #{ current_group.name }")
  end

  scenario "Following the view all people link", js: true do
    current_group = team
    add_people_to_group(names, current_group)

    javascript_log_in
    visit group_path(current_group)

    click_link("View all people in #{ current_group.name }")
    expect(page).to have_text("People in #{ current_group.name }")
    names.each do |name|
      expect(page).to have_link(name.join(' '))
    end

    click_link("hide")
    expect(page).not_to have_text("People in #{ current_group.name }")
    expect(page).to have_link("View all people in #{ current_group.name }")

    click_link("View all people in #{ current_group.name }")
    expect(page).to have_css('.team-member', count: 3)
  end
end

def add_people_to_group(names, group)
  names.each do |gn, sn|
    person = create(:person, given_name: gn, surname: sn)
    membership = create(:membership, person: person, group: group)
  end
end

def names
  names = [
    %w[Johnny Cash],
    %w[Dolly Parton],
    %w[Merle Haggard],
  ]
end


