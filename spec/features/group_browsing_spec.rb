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
    expect(page).not_to have_link("A Leaf")

    click_link "A Team"
    expect(page).to have_link("A Leaf Node")
  end

  scenario "Viewing all the people in an organisation (group with children) " do
    add_named_people_to_group(org)
    visit group_path(org)

    names.each do |name|
      expect(page).to have_text(name.join(' '))
    end
  end

  scenario "Listing all the people in a leaf node (group without children) " do
    add_named_people_to_group(leaf_node)
    visit group_path(leaf_node)

    names.each do |name|
      expect(page).to have_text(name.join(' '))
    end
  end
end

def add_named_people_to_group(group)
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


