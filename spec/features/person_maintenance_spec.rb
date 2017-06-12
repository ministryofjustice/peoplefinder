require 'rails_helper'

feature 'Person maintenance' do
  include PermittedDomainHelper
  include ActiveJobHelper

  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:another_person) { create(:person, email: 'someone.else@digital.justice.gov.uk') }

  before(:each, user: :regular) do
    omni_auth_log_in_as person.email
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

  context 'Creating a person' do

    context 'for a read only user', user: :readonly do
      scenario 'is not allowed without login' do
        new_profile_page.load

        expect(login_page).to be_displayed
      end
    end

    context 'for a regular user', user: :regular do
      scenario 'Creating a person from a group' do
        department = create(:department)
        team = create(:group, parent: department)
        subteam = create(:group, parent: team)

        cta_text = 'Create a new profile'
        visit group_path(department)
        expect(page).not_to have_selector('a', text: cta_text)

        click_link team.name
        expect(page).not_to have_selector('a', text: cta_text)

        click_link subteam.name
        expect(page).to have_selector('a', text: cta_text)

        click_link cta_text
        expect(page.current_path).to eq(new_person_path)
      end

      scenario 'Creating a person with a complete profile', js: true do
        create(:group, name: 'Digital')

        javascript_log_in
        visit new_person_path
        expect(page).to have_title("New profile - #{app_title}")
        expect(page).not_to have_text(completion_prompt_text)
        fill_in_complete_profile_details

        click_button 'Save', match: :first
        check_creation_of_profile_details
      end

      scenario 'Creating an invalid person' do
        new_profile_page.load
        new_profile_page.form.save.click

        expect(new_profile_page).to have_error_summary
        expect(new_profile_page.error_summary).to have_given_name_error
        expect(new_profile_page.error_summary).to have_surname_error
        expect(new_profile_page.error_summary).to have_email_error
      end

      scenario 'Creating a person with existing e-mail raises an error' do
        existing_person = create(:person)
        new_profile_page.load
        new_profile_page.form.email.set existing_person.email
        new_profile_page.form.save.click
        expect(new_profile_page.error_summary).to have_email_error
      end

      scenario 'Creating a person with invalid e-mail raises an error' do
        new_profile_page.load
        new_profile_page.form.email.set 'invalid email@digital.justice.gov.uk'
        new_profile_page.form.save.click

        expect(new_profile_page.error_summary).to have_email_error
      end

      scenario 'Creating a person with e-mail from an unsupported domain raises an error' do
        new_profile_page.load
        new_profile_page.form.email.set 'name.surname@example.com'
        new_profile_page.form.save.click

        expect(new_profile_page.error_summary).to have_email_error
      end

      scenario 'Creating a person with an identical name', js: true do
        create(:group, name: 'Digital')
        create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])

        javascript_log_in
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

      scenario 'Cancelling creation of a person with an identical name' do
        create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])
        visit new_person_path

        fill_in 'First name', with: person_attributes[:given_name]
        fill_in 'Last name', with: person_attributes[:surname]
        fill_in 'Main email', with: person_attributes[:email]
        click_button 'Save', match: :first

        click_link 'Return to home page'
        expect(Person.where(surname: person_attributes[:surname]).count).to eql(1)
      end

      scenario 'Cancelling a new form' do
        visit new_person_path
        expect(page).to have_link('Cancel', href: 'javascript:history.back()')
      end
    end
  end

  context 'Editing a person' do
    context 'for a read only user', user: :readonly do
      scenario 'is not allowed without login' do
        visit person_path(create(:person, person_attributes))
        click_edit_profile

        expect(login_page).to be_displayed
      end
    end

    context 'for a regular user', user: :regular do
      scenario 'Editing a person' do
        visit person_path(create(:person, person_attributes))
        click_edit_profile

        expect(page).to have_title("Edit profile - #{app_title}")
        expect(page).not_to have_text(completion_prompt_text)
        fill_in 'First name', with: 'Jane'
        fill_in 'Last name', with: 'Doe'
        click_button 'Save', match: :first

        expect(page).to have_content('We have let Jane Doe know that you’ve made changes')
        within('h1') do
          expect(page).to have_text('Jane Doe')
        end
      end

      scenario 'Editing my own profile from a normal edit link' do
        visit person_path(person)
        click_edit_profile
        expect(page).not_to have_text(completion_prompt_text)
      end

      scenario 'Editing my own profile from a "complete your profile" link' do
        visit person_path(person)
        click_link 'complete your profile', match: :first
        expect(page).to have_text(completion_prompt_text)
      end

      scenario 'Editing another person\'s profile from a "complete this profile" link' do
        visit person_path(another_person)
        click_link 'complete this profile', match: :first
        expect(page).to have_text(completion_prompt_text)
      end

      scenario 'Validates required fields' do
        person = create(:person, person_attributes)
        edit_profile_page.load(slug: person.slug)

        edit_profile_page.form.given_name.set ''
        edit_profile_page.form.surname.set ''
        edit_profile_page.form.email.set ''
        edit_profile_page.form.save.click

        expect(edit_profile_page).to have_error_summary
        expect(edit_profile_page.error_summary).to have_given_name_error
        expect(edit_profile_page.error_summary).to have_surname_error
        expect(edit_profile_page.error_summary).to have_email_error
      end

      scenario 'Editing a person to have an existing e-mail raises an error' do
        existing_person = create(:person)

        edit_profile_page.load(slug: person.slug)
        edit_profile_page.form.email.set existing_person.email
        edit_profile_page.form.save.click
        expect(edit_profile_page.error_summary).to have_email_error
      end

      scenario 'Editing a person to have an unpermitted e-mail raises an error' do
        edit_profile_page.load(slug: person.slug)
        edit_profile_page.form.email.set 'whatevers@big.blackhole.com'
        edit_profile_page.form.save.click

        expect(edit_profile_page.error_summary).to have_email_error
      end

      scenario 'Recording audit details' do
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

      scenario 'Editing a person and giving them a name that already exists' do
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

      scenario 'Editing an invalid person' do
        person = create(:person, person_attributes)

        edit_profile_page.load(slug: person.slug)

        edit_profile_page.form.surname.set ''
        edit_profile_page.form.save.click

        expect(edit_profile_page).to have_error_summary
        expect(edit_profile_page.error_summary).to have_surname_error
      end

      scenario 'Cancelling an edit' do
        person = create(:person)
        visit edit_person_path(person)
        expect(page).to have_link('Cancel', href: person_path(person))
      end
    end
  end

  context 'Deleting a person' do
    context 'for a regular user', user: :regular do
      scenario 'Deleting a person' do
        person = create :person
        email_address = person.email
        given_name = person.given_name

        visit person_path(person)
        click_delete_profile
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)

        expect(last_email.to).to include(email_address)
        expect(last_email.subject).to eq('Your profile on MOJ People Finder has been deleted')
        expect(last_email.body.encoded).to match("Hello #{given_name}")
      end

      scenario 'Allow deletion of a person even when there are memberships' do
        membership = create(:membership)
        person = membership.person
        visit person_path(person)
        click_delete_profile
        expect { Membership.find(membership.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'Viewing my own profile', user: :regular do
    scenario 'when it is complete' do
      complete_profile!(person)
      visit person_path(person)
      expect(page).to have_text('Profile completeness 100%')
      expect(page).to have_text('Thanks for improving People Finder for everyone!')
    end

    scenario 'when it is incomplete' do
      visit person_path(person)
      expect(page).to have_text('Profile completeness')
      expect(page).to have_text('complete your profile')
    end
  end

  context 'Viewing another person\'s profile' do

    context 'for the readonly user', user: :readonly do
      scenario 'when it is complete' do
        complete_profile!(another_person)
        visit person_path(another_person)
        expect(page).not_to have_text('Profile completeness')
      end

      scenario 'when it is not complete' do
        visit person_path(another_person)
        expect(page).to have_text('Profile completeness')
        click_link 'complete this profile', match: :first
        expect(login_page).to be_displayed
      end
    end

    context 'for a regular user', user: :regular do
      scenario 'when it is complete' do
        complete_profile!(another_person)
        visit person_path(another_person)
        expect(page).not_to have_text('Profile completeness')
      end

      scenario 'when it is not complete' do
        visit person_path(another_person)
        expect(page).to have_text('Profile completeness')
      end
    end
  end

  scenario 'UI elements on the new/edit pages', user: :regular do
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
