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

  scenario 'A team and subteams without people' do
    current_group = team
    visit group_path(current_group)

    expect(page).to have_text("0% of profile information completed")
    expect(page).not_to have_link("View all 0 people in #{ current_group.name }")
    expect(page).not_to have_link("View 0 people not assigned to a sub-team")
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
    expect(page).not_to have_link("View all 0 people in #{ current_group.name }")
    expect(page).not_to have_link("View 0 people not assigned to a sub-team")
  end

  context 'A team with people and subteams with people' do
    before do
      current_group = team
      add_people_to_group(names, current_group)
      add_people_to_group(subteam_names, subteam)
    end

    scenario 'viewing top level group' do
      add_people_to_group([%w[Perm Sec]], department)

      visit group_path(department)
      expect(page).not_to have_link("View all 7 people in #{ department.name }")
      expect(page).to have_link("View 1 person not assigned to a sub-team")
    end

    scenario 'viewing text on page' do
      visit group_path(team)
      expect(page).to have_text("Teams within #{ team.name }")
      expect(page).to have_link("View all 6 people in #{ team.name }")
      expect(page).to have_link("View 3 people not assigned to a sub-team")
      expect(page).to have_text("#{subteam.completion_score}% of profile information completed")
    end

    scenario 'following the view all people link' do
      visit group_path(team)
      click_link("View all 6 people in #{ team.name }")

      expect(page).to have_title("People in #{ team.name } - #{ app_title }")
      within('.breadcrumbs') do
        expect(page).to have_link(team.name)
        expect(page).to have_text('All people')
      end

      expect(page).to have_text("People in #{ team.name }")
      names.each do |name|
        expect(page).to have_link(name.join(' '))
      end
    end

    scenario 'following link to view people not assigned to a sub-team' do
      visit group_path(team)
      click_link('View 3 people not assigned to a sub-team')

      expect(page).to have_title("People in #{ team.name } not assigned to a sub-team - #{ app_title }")
      within('.breadcrumbs') do
        expect(page).to have_link(team.name)
        expect(page).to have_text('People not assigned to a sub-team')
      end

      expect(page).to have_text("People in #{ team.name } not assigned to a sub-team")
      names.each do |name|
        expect(page).to have_link(name.join(' '))
      end
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

  def subteam_names
    [
      %w[ Cash Johnny ],
      %w[ Parton Dolly ],
      %w[ Haggard Merle ]
    ]
  end

end
