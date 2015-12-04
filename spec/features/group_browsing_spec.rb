require 'rails_helper'

feature 'Group browsing' do
  include PermittedDomainHelper

  let!(:department) { create(:department) }
  let!(:team) { create(:group, name: 'A Team', parent: department) }
  let!(:subteam) { create(:group, name: 'A Subteam', parent: team) }
  let!(:leaf_node) { create(:group, name: 'A Leaf Node', parent: subteam) }

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Drilling down through groups' do
    visit group_path(department)

    expect(page).to have_title("#{ department.name } - #{ app_title }")
    expect(page).to have_link('A Team')
    expect(page).not_to have_link('A Subteam')

    click_link 'A Team'
    expect(page).to have_link('A Subteam')
    expect(page).not_to have_link('A Leaf Node')

    click_link 'A Subteam'
    expect(page).to have_link('A Leaf Node')
  end

  scenario 'A team with people and subteams with people' do
    current_group = team
    add_people_to_group(names, current_group)
    add_people_to_group(names, subteam)
    visit group_path(current_group)

    expect(page).to have_text("Teams within #{ current_group.name }")
    expect(page).to have_link("View all 6 people in #{ current_group.name }")
    expect(page).to have_text("#{subteam.completion_score}% of profile information completed")
  end

  scenario 'A team and subteams without people' do
    current_group = team
    visit group_path(current_group)

    expect(page).to have_text("0% of profile information completed")
  end

  scenario 'A team with no subteams (leaf_node) and some people' do
    current_group = leaf_node
    add_people_to_group(names, current_group)
    visit group_path(current_group)

    expect(page).not_to have_text("Teams within #{ current_group.name }")
    expect(page).to have_text("People in #{ current_group.name }")
    names.each do |name|
      expect(page).to have_text(name.join(' '))
    end
  end

  scenario 'A team with no subteams (leaf_node) and no people' do
    current_group = leaf_node
    visit group_path(leaf_node)

    expect(page).not_to have_text("Teams within #{ current_group.name }")
    expect(page).not_to have_link("View all people in #{ current_group.name }")
  end

  scenario 'Following the view all people link' do
    current_group = team
    add_people_to_group(names, current_group)
    visit group_path(current_group)
    click_link("View all 3 people in #{ current_group.name }")

    expect(page).to have_title("People in #{ current_group.name } - #{ app_title }")
    within('.breadcrumbs') do
      expect(page).to have_link(current_group.name)
      expect(page).to have_text('All people')
    end

    expect(page).to have_text("People in #{ current_group.name }")
    names.each do |name|
      expect(page).to have_link(name.join(' '))
    end
  end

  scenario 'redirecting from /groups' do
    create(:group, name: 'moj')

    visit '/groups/moj'
    expect(current_path).to eql('/teams/moj')

    visit '/groups/moj/edit'
    expect(current_path).to eql('/teams/moj/edit')

    visit '/groups/moj/people'
    expect(current_path).to eql('/teams/moj/people')
  end

  def add_people_to_group(names, group)
    names.each do |gn, sn|
      person = create(:person, given_name: gn, surname: sn)
      create(:membership, person: person, group: group)
    end
  end

  def names
    [
      %w[ Johnny Cash ],
      %w[ Dolly Parton ],
      %w[ Merle Haggard ]
    ]
  end
end
