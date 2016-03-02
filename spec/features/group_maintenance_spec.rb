require 'rails_helper'

feature 'Group maintenance' do
  include PermittedDomainHelper
  include ActiveJobHelper

  let(:login_page) { Pages::Login.new }

  let(:dept) { create(:department) }

  before(:each, user: :regular) do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  before(:each, user: :readonly) do
    page.driver.browser.header('RO', 'ENABLED')
  end

  def visit_edit_view group
    javascript_log_in
    visit group_path(group)
    click_link 'Edit'
  end

  context 'for a regular user', user: :regular do
    scenario 'Creating a top-level department' do
      name = 'Ministry of Justice'

      visit new_group_path
      expect(page).to have_title("New team - #{app_title}")

      fill_in 'Team name', with: name
      fill_in 'Team description', with: 'about my team'
      click_button 'Save'

      expect(page).to have_content('Created Ministry of Justice')

      dept = Group.find_by_name(name)
      expect(dept.name).to eql(name)
      expect(dept.description).to eql('about my team')
      expect(dept.parent).to be_nil
    end

    scenario 'Creating a team inside the department', js: true do
      javascript_log_in
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

    scenario 'Creating a subteam inside a team from that team\'s page' do
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

    scenario 'Creating a team and choosing the parent from the org browser', js: true do
      create(:group, name: 'Corporate Services')

      javascript_log_in
      visit new_group_path

      fill_in 'Team name', with: 'Digital Services'
      click_on_subteam_in_org_browser 'Corporate Services'
      click_button 'Save'

      within('.breadcrumbs ol') do
        expect(page).to have_content('Corporate Services Digital Services')
      end
    end

    scenario 'Deleting a team' do
      group = create(:group)
      visit edit_group_path(group)
      expect(page).to have_text('cannot be undone')
      click_link('Delete this team')

      expect(page).to have_content("Deleted #{group.name}")
      expect { Group.find(group.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    scenario 'Prevent deletion of a team that has memberships' do
      membership = create(:membership)
      group = membership.group
      visit edit_group_path(group)
      expect(page).not_to have_link('Delete this team')
      expect(page).to have_text('deletion is only possible if there are no people')
    end

    let(:parent_group) { create(:group, name: 'CSG', parent: dept) }
    let(:sibling_group) { create(:group, name: 'Technology', parent: parent_group) }
    let(:group_three_deep) { create(:group, name: 'Digital Services', parent: parent_group) }

    def setup_three_level_group
      sibling_group
      group_three_deep
    end

    def setup_group_member group
      user = create(:person)
      create :membership, person: user, group: group, subscribed: true
      user
    end

    scenario 'Editing a team name', js: true do
      group = setup_three_level_group
      user = setup_group_member group
      visit_edit_view(group)

      expect(page).to have_title("Edit team - #{app_title}")
      expect(page).to have_text('You are currently editing this profile')
      new_name = 'Cyberdigital Cyberservices'
      fill_in 'Team name', with: new_name

      click_button 'Save'

      expect(page).to have_content('Updated Cyberdigital Cyberservices')
      expect(page).not_to have_text('You are currently editing this profile')
      group.reload
      expect(group.name).to eql(new_name)

      expect(last_email.to).to include(user.email)
      expect(last_email.subject).to eq('People Finder team updated')
      expect(page).to have_text(new_name)
      expect(last_email.body.encoded).to match(group_url(group))
    end

    scenario 'Changing a team parent via clicking "Back"', js: true do
      group = setup_three_level_group
      setup_group_member group
      expect(dept.name).to eq 'Ministry of Justice'
      visit_edit_view(group)

      expect(page).to have_selector('.editable-fields', visible: :hidden)
      within('.group-parent') { click_link 'Edit' }
      expect(page).to have_selector('.editable-fields', visible: :visible)

      within('.team.selected') { click_link 'Back' }
      expect(page).to have_selector('a.team-link', text: /#{dept.name}/, visible: :visible)
      click_button 'Save'

      group.reload
      expect(group.parent).to eql(dept)
    end

    scenario 'Changing a team parent via clicking sibling team name', js: true do
      group = setup_three_level_group
      setup_group_member group
      visit_edit_view(group)

      within('.group-parent') { click_link 'Edit' }
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

    scenario 'Changing a team parent via clicking sibling team\'s subteam name', js: true do
      group = setup_three_level_group
      subteam_group = create(:group, name: 'Test team', parent: sibling_group)
      setup_group_member group
      visit_edit_view(group)

      within('.group-parent') { click_link 'Edit' }
      within('.team.selected') do
        expect(page).to have_link("#{sibling_group.name} 1 sub-team")
        click_link "#{sibling_group.name} 1 sub-team"
      end

      within('.team.selected') do
        expect(page).to have_link(subteam_group.name)
        click_link subteam_group.name
      end
      within('.editable-fields') do
        click_link 'Done'
      end

      click_button 'Save'

      group.reload
      expect(group.parent).to eql(subteam_group)
    end

    scenario 'Showing the acronym', js: true do
      group = create(:group, name: 'HM Courts and Tribunal Service', acronym: 'HMCTS')

      javascript_log_in
      visit group_path(group)

      within('.group-title h1') do
        expect(page).to have_text('HMCTS')
      end

      click_link 'Edit'
      fill_in 'Team initials', with: ''
      click_button 'Save'

      expect(page).not_to have_text('HMCTS')
      expect(page).not_to have_selector('.group-title h2')
    end

    scenario 'Not responding to the selection of impossible parent nodes', js: true do
      parent_group = create(:group, name: 'CSG', parent: dept)
      group = create(:group, name: 'Digital Services', parent: parent_group)
      visit_edit_view(group)

      new_name = 'Cyberdigital Cyberservices'
      fill_in 'Team name', with: new_name

      within('.group-parent') do
        click_link 'Edit'
      end

      click_on_subteam_in_org_browser 'Digital Services'
      click_button 'Save'

      group.reload
      expect(group.name).to eql(new_name)
      expect(group.parent).to eql(parent_group)
    end

    scenario 'UI elements on the new/edit pages' do
      visit new_group_path
      expect(page).not_to have_selector('.search-box')
      expect(page).to have_text('You are currently editing this profile')

      fill_in 'Team name', with: 'Digital'
      click_button 'Save'
      expect(page).to have_selector('.search-box')
      expect(page).not_to have_text('You are currently editing this profile')

      click_link 'Edit this team'
      expect(page).not_to have_selector('.search-box')
      expect(page).to have_text('You are currently editing this profile')
    end

    scenario 'Cancelling an edit' do
      group = create(:group)
      visit edit_group_path(group)
      expect(page).to have_link('Cancel', href: group_path(group))
    end

    scenario 'Cancelling a new form' do
      visit new_group_path
      expect(page).to have_link('Cancel', href: 'javascript:history.back()')
    end

    scenario 'Not displaying an edit parent field for a department' do
      dept = create(:group).parent

      visit edit_group_path(dept)
      expect(page).not_to have_selector('.org-browser')
    end
  end

  context 'for a readonly user', user: :readonly do
    scenario 'Is not allowed to create a new team' do
      visit group_path(dept)
      click_link 'Add new sub-team'

      expect(login_page).to be_displayed
    end

    scenario 'Is not allowed to edit a team' do
      group = create(:group, name: 'Digital Services', parent: dept)

      visit edit_group_path(group)

      expect(login_page).to be_displayed
    end
  end
end
