require 'rails_helper'

feature "Group maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a top-level organisation" do
    name = "An Organisation"
    visit new_group_path
    fill_in "Name", with: name
    click_button "Create Group"

    org = Group.find_by_name(name)
    expect(org.name).to eql(name)
    expect(org.parent).to be_nil
  end

  scenario "Creating a team inside an organisation" do
    org = create(:group)

    name = "A Team"
    visit new_group_path
    fill_in "Name", with: name
    select org.name, from: "Parent"
    click_button "Create Group"

    team = Group.find_by_name(name)
    expect(team.name).to eql(name)
    expect(team.parent).to eql(org)
  end

  scenario 'Deleting a group softly' do
    membership = create(:membership)
    group = membership.group
    visit edit_group_path(group)
    click_link('Delete this record')

    expect { Group.find(group) }.to raise_error(ActiveRecord::RecordNotFound)
    expect { Membership.find(membership) }.to raise_error(ActiveRecord::RecordNotFound)

    expect(Group.with_deleted.find(group)).to eql(group)
    expect(Membership.with_deleted.find(membership)).to eql(membership)
  end
end

