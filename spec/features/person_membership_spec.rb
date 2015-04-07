require 'rails_helper'

feature "Person maintenance" do
  include PermittedDomainHelper

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a person and making them the leader of a group', js: true do
    group = create(:group, name: 'Digital Justice')
    javascript_log_in

    visit new_person_path
    fill_in 'Surname', with: 'Taylor'
    fill_in 'Email', with: person_attributes[:email]
    fill_in 'Job title', with: 'Head Honcho'
    select_in_team_select 'Digital Justice'
    check 'leader'
    click_button 'Save'

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
    expect(membership).to be_subscribed
  end

  scenario 'Editing a job title', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)

    fill_in 'Job title', with: 'Head Honcho'
    click_button 'Save'

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
  end

  scenario 'Adding an additional role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications')

    javascript_log_in
    visit edit_person_path(person)

    click_link('Add another role')
    sleep 1

    within all('#memberships .membership').last do
      select_in_team_select 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Save'
    expect(Person.last.memberships.length).to eql(2)
  end

  scenario 'Unsubscribing from notifications', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)

    fill_in 'Job title', with: 'Head Honcho'
    uncheck 'Team updates'
    click_button 'Save'

    membership = Person.last.memberships.last
    expect(membership).not_to be_subscribed
  end

  scenario 'Clicking the add another role link', js: true do
    create(:group)

    javascript_log_in
    visit new_person_path

    click_link('Add another role')
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
