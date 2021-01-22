require 'rails_helper'

describe 'Group maintenance' do
  include PermittedDomainHelper
  include ActiveJobHelper

  let(:login_page) { Pages::Login.new }

  let(:dept) { create(:department) }

  before(:each, user: :regular) do
    token_log_in_as 'test.user@digital.justice.gov.uk'
  end

  before(:each, user: :readonly) do
    mock_readonly_user
  end

  def visit_edit_view group
    visit group_path(group)
    click_link 'Edit'
  end

  context 'when a regular user', user: :regular, js: true do
    before do
      dept
    end

    let(:group_three_deep) { create(:group, name: 'Digital Services', parent: parent_group) }
    let(:sibling_group) { create(:group, name: 'Technology', parent: parent_group) }
    let(:parent_group) { create(:group, name: 'CSG', parent: dept) }
    it 'Creating a top-level department' do
      Group.destroy_all
      name = 'Ministry of Justice'
      visit new_group_path
      expect(page).to have_title("Create a team - #{app_title}")

      fill_in 'Team name', with: name
      fill_in 'Team description', with: 'about my team'
      click_button 'Save'

      expect(page).to have_content('Created Ministry of Justice')

      dept = Group.find_by_name(name)
      expect(dept.name).to eql(name)
      expect(dept.description).to eql('about my team')
      expect(dept.parent).to be_nil
    end

    it 'Creating a team inside the department' do
      visit group_path(dept)
      click_link 'Add new sub-team'

      name = 'CSG'
      fill_in 'Team name', with: name
      click_button 'Save'

      expect(page).to have_content('Created CSG')

      team = Group.find_by_name(name)
      expect(team.name).to eql(name)
      expect(team.parent).to eql(dept)
    end

    it 'Creating a subteam inside a team from that team\'s page' do
      team = create(:group, parent: dept, name: 'Corporate Services')
      visit group_path(team)
      click_link 'Add new sub-team'

      name = 'Digital Services'
      fill_in 'Team name', with: name
      click_button 'Save'

      expect(page).to have_content('Created Digital Services')

      subteam = Group.find_by_name(name)
      expect(subteam.name).to eql(name)
      expect(subteam.parent).to eql(team)
    end

    it 'Creating a team and choosing the parent from the org browser' do
      create(:group, name: 'Corporate Services')

      visit new_group_path

      fill_in 'Team name', with: 'Digital Services'
      click_on_subteam_in_org_browser 'Corporate Services'
      click_button 'Save'

      within('.breadcrumbs ol') do
        expect(page).to have_selector('li.breadcrumb-2', text: 'Corporate Services')
        expect(page).to have_selector('li.breadcrumb-3', text: 'Digital Services')
      end
    end

    it 'Deleting a team' do
      group = create(:group)
      visit edit_group_path(group)
      expect(page).to have_text('cannot be undone')
      page.accept_confirm do
        click_link('Delete this team')
      end

      expect(page).to have_content("Deleted #{group.name}")
      expect { Group.find(group.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'Prevent deletion of a team that has memberships' do
      membership = create(:membership)
      group = membership.group
      visit edit_group_path(group)
      expect(page).not_to have_link('Delete this team')
      expect(page).to have_text('deletion is only possible if there are no people')
    end

    def setup_three_level_group
      sibling_group
      group_three_deep
    end

    def setup_group_member group
      user = create(:person)
      create :membership, person: user, group: group, subscribed: true
      user
    end

    it 'Editing a team name' do
      group = setup_three_level_group
      user = setup_group_member group
      visit_edit_view(group)

      expect(page).to have_title("Edit team - #{app_title}")
      expect(page).not_to have_selector('.mod-search-form')
      new_name = 'Cyberdigital Cyberservices'
      fill_in 'Team name', with: new_name

      click_button 'Save'

      expect(page).to have_content('Updated Cyberdigital Cyberservices')
      expect(page).to have_selector('.mod-search-form')
      group.reload
      expect(group.name).to eql(new_name)

      expect(last_email.to).to include(user.email)
      expect(last_email.subject).to eq('People Finder team updated')
      expect(page).to have_text(new_name)
      expect(last_email.body.encoded).to match(group_url(group))
    end

    it 'Change parent to department via clicking "Back"' do
      group = setup_three_level_group
      setup_group_member group
      expect(dept.name).to eq 'Ministry of Justice'
      visit_edit_view(group)

      expect(page).to have_selector('.editable-fields', visible: :hidden)
      within('.group-parent') { click_link 'Change team parent' }
      expect(page).to have_selector('.editable-fields', visible: :visible)

      within('.team.selected') { click_link 'Back' }
      expect(page).to have_selector('a.team-link', text: /#{dept.name}/, visible: :visible)
      click_button 'Save'

      group.reload
      expect(group.parent).to eql(dept)
    end

    it 'Changing a team parent via clicking sibling team name' do
      group = setup_three_level_group
      setup_group_member group
      visit_edit_view(group)

      within('.group-parent') { click_link 'Change team parent' }
      within('.team.selected') do
        expect(page).to have_link(sibling_group.name)
        click_link sibling_group.name
      end
      within('.editable-fields') do
        click_link 'Done'
      end

      click_button 'Save'

      group.reload
      expect(group.parent).to eql(sibling_group)
    end

    it 'Changing a team parent via clicking sibling team\'s subteam name', skip: 'skip until capybara/poltegeist update to try and fix as flickers regularly after site_prism bump to 2.9' do
      group = setup_three_level_group
      subteam_group = create(:group, name: 'Test team', parent: sibling_group)
      setup_group_member group
      group.memberships.reload # seems to help flicker
      visit_edit_view(group)

      within('.group-parent') { click_link 'Change team parent' }

      within('.team.selected') do
        expect(page).to have_link("#{sibling_group.name} 1 sub-team")
        click_link "#{sibling_group.name} 1 sub-team", wait: 6
        expect(page).to have_link(subteam_group.name)
        click_link subteam_group.name, wait: 6
      end

      within('.editable-fields') do
        click_link 'Done', wait: 6
      end

      using_wait_time 6 do
        expect(page).to have_selector('.show-editable-fields', visible: :visible)
        expect(page).to have_selector('.parent-summary', text: /Test team/)
      end

      click_button 'Save'

      group.reload
      expect(group.parent).to eql(subteam_group)
    end

    it 'Showing the acronym' do
      group = create(:group, name: 'HM Courts and Tribunal Service', acronym: 'HMCTS')

      visit group_path(group)

      within('.mod-heading h1') do
        expect(page).to have_text('HMCTS')
      end

      click_link 'Edit'
      fill_in 'Team initials', with: ''
      click_button 'Save'

      expect(page).not_to have_text('HMCTS')
      expect(page).not_to have_selector('.group-title h2')
    end

    it 'Not responding to the selection of impossible parent nodes' do
      parent_group = create(:group, name: 'CSG', parent: dept)
      group = create(:group, name: 'Digital Services', parent: parent_group)
      visit_edit_view(group)

      new_name = 'Cyberdigital Cyberservices'
      fill_in 'Team name', with: new_name

      within('.group-parent') do
        click_link 'Change team parent'
      end

      click_on_subteam_in_org_browser 'Digital Services'
      click_button 'Save'

      group.reload
      expect(group.name).to eql(new_name)
      expect(group.parent).to eql(parent_group)
    end

    it 'UI elements on the new/edit pages' do
      visit new_group_path
      expect(page).not_to have_selector('.mod-search-form')

      fill_in 'Team name', with: 'Digital'
      select_in_parent_team_select 'Ministry of Justice'
      click_button 'Save'
      expect(page).to have_selector('.mod-search-form')

      click_link 'Edit this team'
      expect(page).not_to have_selector('.mod-search-form')
    end

    it 'Cancelling an edit' do
      group = create(:group)
      visit edit_group_path(group)
      expect(page).to have_link('Cancel', href: group_path(group))
    end

    it 'Cancelling a new form' do
      visit new_group_path
      expect(page).to have_link('Cancel', href: 'javascript:history.back()')
    end

    it 'Not displaying an edit parent field for a department' do
      dept = create(:group).parent

      visit edit_group_path(dept)
      expect(page).not_to have_selector('.org-browser')
    end
  end

  context 'when a readonly user', user: :readonly do
    it 'Is not allowed to create a new team' do
      visit group_path(dept)
      click_link 'Add new sub-team'
      expect(login_page).to be_displayed
    end

    it 'Is not allowed to edit a team' do
      group = create(:group, name: 'Digital Services', parent: dept)
      visit edit_group_path(group)
      expect(login_page).to be_displayed
    end
  end
end
