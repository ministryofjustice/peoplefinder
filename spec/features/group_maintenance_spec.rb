require 'rails_helper'

feature "Group maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a top-level department" do
    name = "Ministry of Justice"

    visit new_group_path
    fill_in "Name", with: name
    click_button "Create Group"

    expect(page).to have_content("Created Ministry of Justice")

    dept = Group.find_by_name(name)
    expect(dept.name).to eql(name)
    expect(dept.parent).to be_nil
  end

  scenario "Creating an organisation inside the department" do
    dept = create(:group, name: "Ministry of Justice")

    visit group_path(dept)
    click_link "Add an organisation"

    name = "CSG"
    fill_in "Name", with: name
    select dept.name, from: "Parent"
    click_button "Create Group"

    expect(page).to have_content("Created CSG")

    org = Group.find_by_name(name)
    expect(org.name).to eql(name)
    expect(org.parent).to eql(dept)
  end

  scenario "Creating a team inside an organisation from the organisation's page" do
    dept = create(:group, name: "Ministry of Justice")
    org = create(:group, parent: dept)

    visit group_path(org)
    click_link "Add a team"

    name = "Digital Services"
    fill_in "Name", with: name
    click_button "Create Group"

    expect(page).to have_content("Created Digital Services")

    team = Group.find_by_name(name)
    expect(team.name).to eql(name)
    expect(team.parent).to eql(org)
  end

  scenario 'Creating a group and adding a leader' do
    person = create(:person, surname: 'Doe')
    visit new_group_path
    fill_in 'Name', with: 'Cleaners'
    select 'Doe', from: 'Name'
    fill_in 'Title', with: 'Head Honcho'
    check('Leader')
    click_button "Create Group"

    membership = Group.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.person).to eql(person)
    expect(membership.leader?).to be true
  end

  scenario 'Editing a group and linking to the new person page' do
    visit edit_group_path(create(:group))
    click_link 'Add a new person'
    expect(page).to have_text('New person')
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

  scenario 'Deleting a group softly' do
    membership = create(:membership)
    group = membership.group
    visit edit_group_path(group)
    click_link('Delete this record')

    expect(page).to have_content("Deleted #{group.name}")

    expect { Group.find(group) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { Membership.find(membership) }.to raise_error(ActiveRecord::RecordNotFound)

    expect(Group.with_deleted.find(group)).to eql(group)
    expect(Membership.with_deleted.find(membership)).to eql(membership)
  end

  scenario "Editing a group" do
    dept = create(:group, name: "Ministry of Justice")
    org = create(:group, name: "CSG", parent: dept)
    group = create(:group, name: "Digital Services", parent: org)

    visit group_path(group)
    click_link "Edit"

    new_name = "Cyberdigital Cyberservices"
    fill_in "Name", with: new_name
    select dept.name, from: "Parent"
    click_button "Update Group"

    expect(page).to have_content("Updated Cyberdigital Cyberservices")

    group.reload
    expect(group.name).to eql(new_name)
    expect(group.parent).to eql(dept)
  end
end

