require 'rails_helper'

describe 'Person maintenance' do
  include PermittedDomainHelper
  include ActiveJobHelper

  let(:department) { create(:department) }
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:another_person) { create(:person, email: 'someone.else@digital.justice.gov.uk') }

  before do
    department
  end

  before(:each, user: :regular) do
    token_log_in_as person.email
  end

  before(:each, user: :readonly) do
    mock_readonly_user
  end

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:new_profile_page) { Pages::NewProfile.new }
  let(:profile_page) { Pages::Profile.new }
  let(:login_page) { Pages::Login.new }
  let(:email_confirm_page) { Pages::PersonEmailConfirm.new }

  let(:completion_prompt_text) do
    'Fill in the highlighted fields to achieve 100% profile completion'
  end

  context 'when Creating a person' do

    context 'with a read only user', user: :readonly do
      it 'is not allowed without login' do
        new_profile_page.load
        expect(login_page).to be_displayed
      end
    end

    context 'when a regular user', user: :regular do
      it 'Creating a person from a group' do
        team = create(:group)
        subteam = create(:group, parent: team)

        cta_text = 'Create a new profile'
        visit group_path(department)
        expect(page).not_to have_selector('a', text: cta_text)

        click_link team.name
        expect(page).not_to have_selector('a', text: cta_text)

        click_link subteam.name
        expect(page).to have_selector('a', text: cta_text)

        click_link cta_text
        expect(page).to have_current_path(new_person_path, ignore_query: true)
      end

      it 'Creating a person with a complete profile', js: true do
        create(:group, name: 'Digital')

        visit new_person_path
        expect(page).to have_title("New profile - #{app_title}")
        expect(page).not_to have_text(completion_prompt_text)
        fill_in_complete_profile_details

        click_button 'Save', match: :first
        check_creation_of_profile_details
      end

      it 'Creating an invalid person' do
        new_profile_page.load
        new_profile_page.form.save.click

        expect(new_profile_page).to have_error_summary
        expect(new_profile_page.error_summary).to have_given_name_error
        expect(new_profile_page.error_summary).to have_surname_error
        expect(new_profile_page.error_summary).to have_email_error
      end

      it 'Creating a person with existing e-mail raises an error' do
        existing_person = create(:person)
        new_profile_page.load
        new_profile_page.form.email.set existing_person.email
        new_profile_page.form.save.click
        expect(new_profile_page.error_summary).to have_email_error
      end

      it 'Creating a person with invalid e-mail raises an error' do
        new_profile_page.load
        new_profile_page.form.email.set 'invalid email@digital.justice.gov.uk'
        new_profile_page.form.save.click

        expect(new_profile_page.error_summary).to have_email_error
      end

      it 'Creating a person with e-mail from an unsupported domain raises an error' do
        new_profile_page.load
        new_profile_page.form.email.set 'name.surname@example.com'
        new_profile_page.form.save.click

        expect(new_profile_page.error_summary).to have_email_error
      end

      it 'Creating a person with no team membership raises a membership required error and builds empty membership', js: true do
        visit new_person_path
        expect(new_profile_page).to be_displayed
        fill_in 'First name', with: person_attributes[:given_name]
        fill_in 'Last name', with: person_attributes[:surname]
        fill_in 'Main email', with: person_attributes[:email]
        within last_membership do
          click_link 'Leave team'
        end
        expect(new_profile_page.form).to have_membership_panels count: 0
        click_button 'Save', match: :first
        expect(new_profile_page.form).to have_membership_panels count: 1
        expect(new_profile_page).to have_error_summary
        expect(new_profile_page.error_summary).to have_team_membership_required_error
      end

      it 'Creating a person with a team membership but no team chosen raises a team required error', js: true do
        visit new_person_path
        expect(new_profile_page).to be_displayed
        fill_in 'First name', with: person_attributes[:given_name]
        fill_in 'Last name', with: person_attributes[:surname]
        fill_in 'Main email', with: person_attributes[:email]
        fill_in 'Job title', match: :first, with: 'dude'

        click_button 'Save', match: :first
        expect(new_profile_page).to have_error_summary
        expect(new_profile_page.error_summary).to have_team_required_error
      end

      it 'Creating a person with an identical name', js: true do
        create(:group, name: 'Digital')
        create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])

        visit new_person_path
        fill_in_complete_profile_details

        click_button 'Save', match: :first

        expect(page).to have_selector('.error-summary', text: 'The profile you are creating matches one or more existing profiles')
        expect(page).to have_text('1 result found')
        expect(page).to_not have_link('Select')
        expect(page).to_not have_selector('.cb-confirmation-select')
        click_button 'Continue, it is not one of these'

        expect(profile_page).to be_displayed
        expect(profile_page.flash_message).to have_selector('.notice', text: /Created .* profile/)
        check_creation_of_profile_details
        expect(Person.where(surname: person_attributes[:surname]).count).to eql(2)
      end

      it 'Cancelling creation of a person with an identical name' do
        create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])
        visit new_person_path

        fill_in 'First name', with: person_attributes[:given_name]
        fill_in 'Last name', with: person_attributes[:surname]
        fill_in 'Main email', with: person_attributes[:email]
        click_button 'Save', match: :first

        click_link 'Return to home page'
        expect(Person.where(surname: person_attributes[:surname]).count).to eql(1)
      end

      it 'Cancelling a new form' do
        visit new_person_path
        expect(page).to have_link('Cancel', href: 'javascript:history.back()')
      end
    end
  end

  context 'when Editing a person' do
    context 'with a read only user', user: :readonly do
      it 'is not allowed without login' do
        visit person_path(create(:person, person_attributes))
        click_edit_profile
        expect(login_page).to be_displayed
      end
    end

    context 'with a regular user', user: :regular do
      it 'Editing a person', js: true do
        visit person_path(create(:person, person_attributes))
        click_edit_profile

        expect(page).to have_title("Edit profile - #{app_title}")
        expect(page).not_to have_text(completion_prompt_text)
        fill_in 'First name', with: 'Jane'
        fill_in 'Last name', with: 'Doe'
        click_link 'Change team'
        select_in_team_select 'Ministry of Justice'
        click_button 'Save', match: :first

        expect(page).to have_content('We have let Jane Doe know that you’ve made changes')
        within('h1') do
          expect(page).to have_text('Jane Doe')
        end
      end

      it 'Editing my own profile from a normal edit link' do
        visit person_path(person)
        click_edit_profile
        expect(page).not_to have_text(completion_prompt_text)
      end

      it 'Editing my own profile from a "complete your profile" link' do
        visit person_path(person)
        click_link 'complete your profile', match: :first
        expect(page).to have_text(completion_prompt_text)
      end

      it 'Editing another person\'s profile from a "complete this profile" link' do
        visit person_path(another_person)
        click_link 'complete this profile', match: :first
        expect(page).to have_text(completion_prompt_text)
      end

      it 'Validates required fields on person' do
        visit person_path(another_person)
        click_edit_profile
        fill_in 'First name', with: ''
        fill_in 'Last name', with: ''
        fill_in 'Main email address', with: ''
        click_button 'Save', match: :first

        expect(edit_profile_page).to have_error_summary
        expect(edit_profile_page.error_summary).to have_given_name_error
        expect(edit_profile_page.error_summary).to have_surname_error
        expect(edit_profile_page.error_summary).to have_email_error
      end

      it 'Validates required fields on team memberships', js: true do
        visit person_path(another_person)
        click_edit_profile
        click_link 'Join another team'
        expect(edit_profile_page).to have_selector('.membership.panel', count: 2)
        click_button 'Save', match: :first
        expect(edit_profile_page.error_summary).to have_team_required_error text: 'Team is required', count: 1
        expect(edit_profile_page.form).to have_team_required_field_errors text: 'Team is required', count: 1
      end

      it 'Validates existence of at least one team membership', js: true do
        visit person_path(another_person)
        expect(another_person.memberships.count).to eql 1
        click_edit_profile
        expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 1)
        click_link 'Leave team'
        expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 0)
        click_button 'Save', match: :first
        expect(edit_profile_page.error_summary).to have_team_membership_required_error text: 'Membership of a team is required'
        expect(edit_profile_page.form).to have_team_membership_error_destination_anchor
        expect(another_person.reload.memberships.count).to eql 1
      end

      it 'Validates uniqueness of leader in department', js: true do
        role = 'Boss'
        create(:person, :member_of, team: department, role: role, leader: true)

        visit person_path(person)
        click_edit_profile
        expect(edit_profile_page).to have_selector('.membership.panel', count: 1)
        within '.team-leader' do
          govuk_label_click 'Yes'
        end
        click_button 'Save', match: :first
        expect(edit_profile_page.error_summary).to have_leader_unique_error
        expect(edit_profile_page.error_summary.leader_unique_error).to have_text "#{role} (leader of #{department}) already exists. Select \"No\" or change the current #{role}'s profile first", count: 1
      end

      it 'Editing a person to have an existing e-mail raises an error' do
        existing_person = create(:person)

        edit_profile_page.load(slug: person.slug)
        edit_profile_page.form.email.set existing_person.email
        edit_profile_page.form.save.click
        expect(edit_profile_page.error_summary).to have_email_error
      end

      it 'Editing a person to have an unpermitted e-mail raises an error' do
        edit_profile_page.load(slug: person.slug)
        edit_profile_page.form.email.set 'whatevers@big.blackhole.com'
        edit_profile_page.form.save.click

        expect(edit_profile_page.error_summary).to have_email_error
      end

      it 'Recording audit details' do
        allow_any_instance_of(ActionDispatch::Request).
          to receive(:remote_ip).and_return('1.2.3.4')
        allow_any_instance_of(ActionDispatch::Request).
          to receive(:user_agent).and_return('NCSA Mosaic/3.0 (Windows 95)')

        with_versioning do
          person = create(:person, person_attributes)
          visit edit_person_path(person)

          fill_in 'First name', with: 'Jane'
          click_button 'Save', match: :first
        end

        version = Version.last
        expect(version.ip_address).to eq('1.2.3.4')
        expect(version.user_agent).to eq('NCSA Mosaic/3.0 (Windows 95)')
        expect(version.whodunnit).to eq(person)
      end

      it 'Editing a person and giving them a name that already exists' do
        create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])
        person = create(:person, given_name: 'Bobbie', surname: 'Browne')
        visit edit_person_path(person)

        fill_in 'First name', with: person_attributes[:given_name]
        fill_in 'Last name', with: person_attributes[:surname]
        click_button 'Save', match: :first

        expect(page).to have_title("Duplicate names found - #{app_title}")
        click_button 'Continue'
        expect(Person.where(surname: person_attributes[:surname]).count).to eql(2)
      end

      it 'Editing an invalid person' do
        person = create(:person, person_attributes)

        edit_profile_page.load(slug: person.slug)

        edit_profile_page.form.surname.set ''
        edit_profile_page.form.save.click

        expect(edit_profile_page).to have_error_summary
        expect(edit_profile_page.error_summary).to have_surname_error
      end

      it 'Cancelling an edit' do
        person = create(:person)
        visit edit_person_path(person)
        expect(page).to have_link('Cancel', href: person_path(person))
      end
    end
  end

  context 'when Deleting a person', with_csrf_protection: true, js: true do
    context 'with a regular user', user: :regular do
      it 'Deleting a person' do
        person = create :person

        visit person_path(person)
        accept_alert do
          click_delete_profile
        end
        sleep 1
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'Allow deletion of a person even when there are memberships' do
        membership = create(:membership)
        person = membership.person
        visit person_path(person)
        accept_alert do
          click_delete_profile
        end
        sleep 1
        expect { Membership.find(membership.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'when Viewing my own profile', user: :regular do
    it 'when it is complete' do
      complete_profile!(person)
      visit person_path(person)
      expect(page).to have_text("Profile completeness\n \n \n100%")
      expect(page).to have_text('Thanks for improving People Finder for everyone!')
    end

    it 'when it is incomplete' do
      visit person_path(person)
      expect(page).to have_text('Profile completeness')
      expect(page).to have_text('complete your profile')
    end
  end

  context 'when Viewing another person\'s profile' do

    context 'with the readonly user', user: :readonly do
      it 'when it is complete' do
        complete_profile!(another_person)
        visit person_path(another_person)
        expect(page).not_to have_text('Profile completeness')
      end

      it 'when it is not complete' do
        visit person_path(another_person)
        expect(page).to have_text('Profile completeness')
        click_link 'complete this profile', match: :first
        expect(login_page).to be_displayed
      end
    end

    context 'with a regular user', user: :regular do
      it 'when it is complete' do
        complete_profile!(another_person)
        visit person_path(another_person)
        expect(page).not_to have_text('Profile completeness')
      end

      it 'when it is not complete' do
        visit person_path(another_person)
        expect(page).to have_text('Profile completeness')
      end
    end
  end

  it 'UI elements on the new/edit pages', user: :regular do
    visit new_person_path
    expect(page).not_to have_selector('.mod-search-form')

    fill_in 'First name', with: person_attributes[:given_name]
    fill_in 'Last name', with: person_attributes[:surname]
    fill_in 'Main email', with: person_attributes[:email]
    click_button 'Save', match: :first
    expect(page).to have_selector('.mod-search-form')

    click_edit_profile
    expect(page).not_to have_selector('.mod-search-form')
  end

end
