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
    fill_in 'Main email', with: person_attributes[:email]
    fill_in 'Job title', with: 'Head Honcho'

    # expect(page).to have_selector('.team-led', text: 'Ministry of Justice team')
    # expect(page).to have_selector('.hint', text: 'This person leads the Ministry of Justice team. (More than one person can be selected as team leader.)')

    select_in_team_select 'Digital Justice'

    expect(page).to have_selector('.team-led', text: 'Digital Justice team')
    expect(page).to have_selector('.hint', text: 'Tick this box if this person leads the Digital Justice team. More than one person can be selected as team leader.')
    check 'leader'
    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
    expect(membership).to be_subscribed

    visit group_path(group)
    expect(page).to have_selector('.group-leader h4', text: 'Taylor')
    expect(page).to have_selector('.group-leader .leader-role', text: 'Head Honcho')
  end

  scenario 'Editing a job title', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)
    expect(page).to have_selector('.team-led', text: 'Digital Justice team')

    fill_in 'Job title', with: 'Head Honcho'
    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
  end

  scenario 'Changing team membership via clicking "Back"', js: true do
    group = setup_three_level_team
    person = setup_team_member group

    javascript_log_in
    visit edit_person_path(person)

    expect(page).to have_selector('.editable-fields', visible: :hidden)
    within('.editable-container') { click_link 'Edit team membership' }
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(page).to have_selector('.hide-editable-fields', visible: :visible)

    within('.team.selected') { click_link 'Back' }
    expect(page).to have_selector('a.team-link', text: /#{Group.department.name}/, visible: :visible)

    click_link 'Done'
    expect(page).to have_selector('.editable-fields', visible: :hidden)

    click_button 'Save', match: :first

    person.reload
    expect(person.memberships.last.group).to eql(Group.department)
  end

  scenario 'Adding an additional role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications', parent: Group.department)

    javascript_log_in
    visit edit_person_path(person)

    click_link('Add another role')
    expect(page).to have_selector('.editable-fields', visible: :visible)

    within all('#memberships .membership').last do
      click_link 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Save', match: :first
    expect(Person.last.memberships.length).to eql(2)
  end

  scenario 'Adding an additional leadership role in same team', js: true do
    person = create_person_in_digital_justice
    javascript_log_in
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Surname', with: 'Taylor'
    fill_in 'Job title', with: 'Head Honcho'
    check 'leader'

    click_link('Add another role')
    expect(page).to have_selector('.editable-fields', visible: :visible)

    within all('#memberships .membership').last do
      click_link 'Digital Justice'
      fill_in 'Job title', with: 'Master of None'
      check 'leader'
    end
    click_button 'Save', match: :first

    visit group_path(Group.find_by_name('Digital Justice'))
    expect(page).to have_selector('.group-leader h4', text: 'Samantha Taylor')
    expect(page).to have_selector('.group-leader .leader-role', text: 'Head Honcho, Master of None')

    visit person_path(person)
    expect(page).to have_selector('h3', text: 'Head Honcho, Master of None')
  end

  scenario 'Unsubscribing from notifications', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)

    fill_in 'Job title', with: 'Head Honcho'
    uncheck 'Team updates'
    click_button 'Save', match: :first

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
    expect(page).to have_content("Removed #{person.name} from Digital Justice")
    expect(person.reload.memberships).to be_empty
    expect(current_path).to eql(edit_person_path(person))
  end
end

def create_person_in_digital_justice
  department = create(:department, name: 'Ministry of Justice')
  group = create(:group, name: 'Digital Justice', parent: department)
  person = create(:person)
  person.memberships.create(group: group)
  person
end

def setup_three_level_team
  dept = create(:department, name: 'Ministry of Justice')
  parent_group = create(:group, name: 'CSG', parent: dept)
  @technology = create(:group, name: 'Technology', parent: parent_group)
  create(:group, name: 'Digital Services', parent: parent_group)
end

def setup_team_member group
  subscriber = create(:person)
  create :membership, person: subscriber, group: group, subscribed: true
  subscriber
end

def visit_edit_view group
  javascript_log_in
  visit group_path(group)
  click_link 'Edit'
end
