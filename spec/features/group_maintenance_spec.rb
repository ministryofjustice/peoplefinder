require 'rails_helper'

feature "Group maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a top-level department" do
    name = "Ministry of Justice"

    visit new_group_path
    fill_in "Team name", with: name
    fill_in "Team description", with: 'about my team'
    fill_in "Team responsibilities (optional)", with: 'my responsibilities'
    click_button "Create team"

    expect(page).to have_content("Created Ministry of Justice")

    dept = Group.find_by_name(name)
    expect(dept.name).to eql(name)
    expect(dept.description).to eql('about my team')
    expect(dept.responsibilities).to eql('my responsibilities')
    expect(dept.parent).to be_nil
  end

  scenario "Creating a team inside the department" do
    dept = create(:group, name: "Ministry of Justice")

    visit group_path(dept)
    click_link "Add new sub-team"

    name = "CSG"
    fill_in "Team name", with: name
    select dept.name, from: "Parent"
    click_button "Create team"

    expect(page).to have_content("Created CSG")

    team = Group.find_by_name(name)
    expect(team.name).to eql(name)
    expect(team.parent).to eql(dept)
  end

  scenario "Creating a subteam inside a team from that team's page" do
    dept = create(:group, name: "Ministry of Justice")
    team = create(:group, parent: dept, name: 'Corporate Services')

    visit group_path(team)
    click_link "Add new sub-team"

    name = "Digital Services"
    fill_in "Team name", with: name
    click_button "Create team"

    expect(page).to have_content("Created Digital Services")

    subteam = Group.find_by_name(name)
    expect(subteam.name).to eql(name)
    expect(subteam.parent).to eql(team)
  end

  scenario 'Deleting a team' do
    group = create(:group)
    visit edit_group_path(group)
    expect(page).not_to have_text('deletion is only possible if there are no people')
    click_link('Delete this team')

    expect(page).to have_content("Deleted #{group.name}")
    expect { Group.find(group) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Prevent deletion of a team that has memberships' do
    membership = create(:membership)
    group = membership.group
    visit edit_group_path(group)
    expect(page).not_to have_link('Delete this record')
    expect(page).to have_text('deletion is only possible if there are no people')
  end

  scenario "Editing a team" do
    dept = create(:group, name: "Ministry of Justice")
    org = create(:group, name: "CSG", parent: dept)
    group = create(:group, name: "Digital Services", parent: org)

    visit group_path(group)
    click_link "Edit"

    expect(page).to have_text('You are currently editing this page')
    new_name = "Cyberdigital Cyberservices"
    fill_in "Team name", with: new_name
    select dept.name, from: "Parent"
    click_button "Update team"

    expect(page).to have_content("Updated Cyberdigital Cyberservices")
    expect(page).not_to have_text('You are currently editing this page')
    group.reload
    expect(group.name).to eql(new_name)
    expect(group.parent).to eql(dept)
  end
end
