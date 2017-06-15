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
    fill_in 'First name', with: 'Helen'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Main email', with: person_attributes[:email]
    fill_in 'Job title', with: 'Head Honcho'

    select_in_team_select 'Digital Justice'

    expect(page).to have_selector('.team-led', text: 'Digital Justice team')
    check_leader

    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
    expect(membership).to be_subscribed

    visit group_path(group)
    within('.cb-leaders') do
      expect(page).to have_selector('h4', text: 'Taylor')
      expect(page).to have_text('Head Honcho')
    end
  end

  scenario 'Confirming an identical person with membership details', js: true do
    create(:group, name: 'Digital Justice')
    create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])

    javascript_log_in
    visit new_person_path
    fill_in_complete_profile_details
    fill_in_membership_details('Digital Justice')

    click_button 'Save', match: :first

    expect(page).to have_text('1 result found')
    click_button 'Continue'
    duplicate = Person.find_by(email: person_attributes[:email])
    expect(duplicate.memberships.last).to have_attributes membership_attributes
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
    expect(page).to have_selector('.cb-job-title', text: 'Head Honcho in Digital Justice')
  end

  scenario 'Leaving the job title blank', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)
    expect(page).to have_selector('.team-led', text: 'Digital Justice team')

    fill_in 'Job title', with: ''

    click_button 'Save', match: :first

    within('.profile') { expect(page).not_to have_selector('.cb-job-title') }
  end

  scenario 'Changing team membership via clicking "Back"', js: true do
    group = setup_three_level_team
    person = setup_team_member group

    javascript_log_in
    visit edit_person_path(person)

    expect(page).to have_selector('.editable-fields', visible: :hidden)
    within('.editable-container') { click_link 'Change team' }
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(page).to have_selector('.hide-editable-fields', visible: :visible)

    within('.team.selected') { click_link 'Back' }
    expect(page).to have_selector('a.subteam-link', text: /CSG/, visible: :visible)
    within('.team.selected') { click_link 'CSG' }
    click_link 'Done'
    expect(page).to have_selector('.editable-fields', visible: :hidden)

    click_button 'Save', match: :first

    person.reload
    expect(person.memberships.last.group).to eql(Group.find_by(name: 'CSG'))
  end

  scenario 'Adding a new team', js: true do
    group = setup_three_level_team
    person = setup_team_member group

    javascript_log_in
    visit edit_person_path(person)

    expect(page).to have_selector('.editable-fields', visible: :hidden)
    within('.editable-container') { click_link 'Change team' }
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(page).to have_selector('.button-add-team', visible: :visible)

    find('a.button-add-team').trigger('click')
    expect(page).to have_selector('.new-team', visible: :visible)
    within('.new-team') do
      fill_in 'AddTeam', with: 'New team'
    end
  end

  scenario 'Joining another team with a role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications', parent: Group.department)

    javascript_log_in
    visit edit_person_path(person)

    click_link('Join another team')
    expect(page).to have_selector('.editable-fields', visible: :visible)

    within all('#memberships .membership').last do
      click_link 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Save', match: :first
    expect(Person.last.memberships.length).to eql(2)
  end

  def check_leader(choice = 'Yes')
    within('.team-leader') do
      govuk_label_click(choice)
    end
  end

  scenario 'Adding a permanent secretary', js: true do
    person = create_person_in_digital_justice
    javascript_log_in
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Permanent Secretary'

    expect(leader_question).to match('Is this person the leader of the Digital Justice team?')
    click_link 'Change team'
    select_in_team_select 'Ministry of Justice'
    expect(leader_question).to match('Are you the Permanent Secretary?')
    check_leader

    click_button 'Save', match: :first

    visit group_path(Group.find_by(name: 'Ministry of Justice'))
    within('.cb-leaders') do
      expect(page).to have_selector('h4', text: 'Samantha Taylor')
      expect(page).to have_text('Permanent Secretary')
    end

    visit person_path(person)
    expect(page).to have_selector('h3', text: 'Permanent Secretary')

    visit home_path
    expect(page.find('img.media-object')[:alt]).to have_content 'Current photo of Samantha Taylor'
  end

  scenario 'Adding an additional leadership role in same team', js: true do
    person = create_person_in_digital_justice
    javascript_log_in
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Head Honcho'
    check_leader

    click_link('Join another team')
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(leader_question).to match('Is this person the leader of the team?')
    select_in_team_select 'Digital Justice'
    expect(leader_question).to match('Is this person the leader of the Digital Justice team?')

    within last_membership do
      fill_in 'Job title', with: 'Master of None'
      check_leader
    end

    click_button 'Save', match: :first

    visit group_path(Group.find_by_name('Digital Justice'))
    within('.cb-leaders') do
      expect(page).to have_selector('h4', text: 'Samantha Taylor')
      expect(page).to have_text('Head Honcho, Master of None')
    end

    visit person_path(person)
    expect(page).to have_selector('h3', text: 'Head Honcho, Master of None')
  end

  scenario 'Unsubscribing from notifications', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)

    fill_in 'Job title', with: 'Head Honcho'
    within('.team-subscribed') { govuk_label_click('No') }
    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership).not_to be_subscribed
  end

  scenario 'Clicking Join another team', js: true do
    create(:group)

    javascript_log_in
    visit new_person_path

    click_link('Join another team')
    expect(page).to have_selector('#memberships .membership', count: 2)

    click_link('Leave team', match: :first)
    expect(page).to have_selector('#memberships .membership', count: 1)
  end

  scenario 'Removing a group' do
    person = create_person_in_digital_justice

    visit edit_person_path(person)

    within('#memberships') do
      click_link('Leave team')
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
