require 'rails_helper'

feature "Group maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a group and adding a leader' do
    person = create(:person, surname: 'Doe')
    visit new_group_path
    fill_in 'Name', with: 'Cleaners'
    select 'Doe', from: 'Name'
    fill_in 'Title', with: 'Head Honcho'
    check('Leader')
    click_button "Create group"

    membership = Group.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.person).to eql(person)
    expect(membership.leader?).to be true
  end

  scenario 'Creating a group and linking to the new person page' do
    visit new_group_path
    click_link 'Add a new person'
    expect(page).to have_text('New person')
  end

  scenario 'Editing a group and linking to the new person page' do
    visit edit_group_path(create(:group, name: 'Doe'))
    click_link 'Add a new person'
    expect(page).to have_select('Group', selected: 'Doe')
  end

  scenario 'Clicking the add another person link', js: true do
    javascript_log_in
    visit new_group_path

    click_link('Add another person')
    expect(page).to have_selector('#memberships .membership', count: 2)

    click_link('remove', match: :first)
    expect(page).to have_selector('#memberships .membership', count: 1)
  end

  scenario 'Removing a person' do
    alice = create(:person, surname: 'Alice')
    digital_group = create(:group, name: 'Digital')
    digital_group.memberships.create(person: alice)

    visit edit_group_path(digital_group)
    click_link('remove')

    expect(page).to have_content("Removed Alice from Digital")
    expect(digital_group.reload.memberships).to be_empty
    expect(current_path).to eql(edit_group_path(digital_group))
  end
end
