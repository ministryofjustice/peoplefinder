require 'rails_helper'

feature "Membership maintenance" do
  let!(:person) { create(:person, surname: 'Doe') }
  let!(:group) { create(:group, name: 'Digital Services') }

  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Showing groups and roles on profile page' do
    membership = person.memberships.create!(group: group, role: 'Worker Bee')
    visit person_path(person)
    expect(page).to have_content('Digital Services')
    expect(page).to have_content('Worker Bee')
  end

  scenario "Adding a person from a group's page" do
    visit group_path(group)
    click_link 'Add member'
    select person.name, from: 'Person'
    fill_in 'Role', with: 'Goat farmer'
    click_button 'Create Membership'

    expect(person.memberships.first.role).to eql('Goat farmer')
    expect(person.memberships.first.person).to eql(person)
  end

  scenario "Removing a person from a group" do
    membership = person.memberships.create!(group: group, role: 'Worker Bee')
    visit group_memberships_path(group)
    click_button "Remove"

    expect(group.people).not_to include(person)
  end

  scenario "Removing a group from a person" do
    membership = person.memberships.create!(group: group, role: 'Worker Bee')
    visit person_memberships_path(person)
    click_button "Remove"

    expect(person.groups).not_to include(group)
  end

  scenario "Adding a group from a person's page" do
    visit person_path(person)
    click_link 'Edit groups'
    click_link 'Add group'
    select group.name, from: 'Group'
    fill_in 'Role', with: 'Goat farmer'
    click_button 'Create Membership'

    expect(person.memberships.first.role).to eql('Goat farmer')
    expect(person.memberships.first.group).to eql(group)
  end
end
