require 'rails_helper'

feature "Peoplefinder::Person maintenance" do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a person and making them the leader of a group', js: true do
    group = create(:group, name: 'Digital Justice')
    javascript_log_in

    visit new_person_path
    fill_in 'Surname', with: 'Taylor'
    fill_in 'Job title', with: 'Head Honcho'
    click_in_org_browser 'Digital Justice'
    check 'leader'
    click_button "Create"

    membership = Peoplefinder::Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
  end

  scenario 'Editing a job title', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)
    click_link 'Edit'

    fill_in 'Job title', with: 'Head Honcho'
    click_button 'Update'

    membership = Peoplefinder::Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
  end

  scenario 'Adding an additional role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications')

    javascript_log_in
    visit edit_person_path(person)

    click_link('Add new role')
    sleep 1

    within all('#memberships .membership').last do
      click_in_org_browser 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Update'
    expect(Peoplefinder::Person.last.memberships.length).to eql(2)
  end

  scenario 'Clicking the add another role link', js: true do
    create(:group)

    javascript_log_in
    visit new_person_path

    click_link('Add new role')
    expect(page).to have_selector('#memberships .membership', count: 2)

    click_link('Delete', match: :first)
    expect(page).to have_selector('#memberships .membership', count: 1)
  end

  scenario 'Removing a group' do
    person = create_person_in_digital_justice

    visit edit_person_path(person)

    within('#memberships') do
      click_link('Delete')
    end
    expect(page).to have_content("Removed #{ person.name } from Digital Justice")
    expect(person.reload.memberships).to be_empty
    expect(current_path).to eql(edit_person_path(person))
  end
end

def create_person_in_digital_justice
  department = create(:department, name: 'Digital Justice')
  group = create(:group, name: 'Digital Justice', parent: department)
  person = create(:person)
  person.memberships.create(group: group)
  person
end
