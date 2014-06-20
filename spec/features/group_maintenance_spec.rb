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
end

