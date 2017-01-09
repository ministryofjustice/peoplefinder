require 'rails_helper'

feature 'Login flow' do
  include PermittedDomainHelper

  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:department) { create(:department) }
  let(:current_time) { Time.now }

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:edit_group_page) { Pages::EditGroup.new }
  let(:new_profile_page) { Pages::NewProfile.new }
  let(:profile_page) { Pages::Profile.new }
  let(:login_page) { Pages::Login.new }
  let(:search_page) { Pages::Search.new }
  let(:confirm_page) { Pages::PersonConfirm.new }
  let(:base_page) { Pages::Base.new }

  let(:profile_created_from_login_html) { "Your profile did not exist so we created it for you." }

  def token_login_step_with_expectation
    expect(login_page).to be_displayed
    token_log_in_as(email)
  end

  def expect_profile_created_flash_notice site_prism_page
    expect(site_prism_page).to have_selector('#flash-messages', text: profile_created_from_login_html)
    expect(site_prism_page).to have_link('here', href: /\/people\/[\w\-]+\/edit/)
  end

  describe 'Choosing to login' do
    scenario 'When user logs in for the first time, they see their profile' do
      omni_auth_log_in_as(email)
      expect(profile_page).to be_displayed
    end

    scenario 'When user logs in, their profile page is displayed' do
      login_count = 5
      create(:person_with_multiple_logins, email: email, login_count: login_count)
      omni_auth_log_in_as(email)
      expect(profile_page).to be_displayed
    end

    scenario 'Login counter is updated every time user logs in' do
      login_count = 3
      person = create(:person_with_multiple_logins, email: email, login_count: login_count)
      omni_auth_log_in_as(email)
      person.reload
      expect(person.login_count).to eql(4)
    end

    scenario 'When super user logs in they see the super admin badge in their name' do
      create(:super_admin, email: email)
      omni_auth_log_in_as(email)
      expect(base_page).to have_super_admin_badge
    end

    scenario 'When a normal user logs in they do not see the super admin badge in their name' do
      create(:person, email: email)
      omni_auth_log_in_as(email)
      expect(base_page).to have_no_super_admin_badge
    end
  end

  describe 'Prompted to login' do
    let(:group) { create :group }
    let(:other_person) { create :person }

    context 'when I have a profile' do
      scenario 'creating a new profile redirects via login back to new profile page with NO flash notice' do
        create(:person, email: email)
        visit new_person_path
        token_login_step_with_expectation
        expect(new_profile_page).to be_displayed
        expect(new_profile_page.body).not_to have_selector('#flash-messages')
      end
    end

    context 'when I do not have a profile' do
      scenario 'creating a new profile redirects via login to new profile page and flashes a notice that their own profile was just created' do
        visit new_person_path
        token_login_step_with_expectation
        expect(new_profile_page).to be_displayed
        expect_profile_created_flash_notice(new_profile_page)
      end

      scenario 'editing a team redirects via login to edit group page and flashes a notice that their own profile was just created' do
        visit edit_group_path group
        token_login_step_with_expectation
        expect(edit_group_page).to be_displayed
        expect_profile_created_flash_notice(edit_group_page)
      end

      scenario 'editing a profile redirects via login to edit profile page and flashes a notice that their own profile was just created' do
        visit edit_person_path other_person
        token_login_step_with_expectation
        expect(edit_profile_page).to be_displayed
        expect_profile_created_flash_notice(edit_profile_page)
      end

      context 'and I have namesakes' do
        let(:email) { 'john.doe3@digital.justice.gov.uk' }
        before do
          create(:person, given_name: 'John', surname: 'Doe', email: 'john.doe@digital.justice.gov.uk')
          create(:person, given_name: 'John', surname: 'Doe', email: 'john.doe2@digital.justice.gov.uk')
        end
        scenario 'creating a new team renders the profile creation confirmation page' do
          visit new_group_path
          token_login_step_with_expectation
          expect(confirm_page).to be_displayed
          expect(confirm_page).to have_content "Create profile"
          expect(confirm_page.form).to be_all_there
          expect(confirm_page.form).to have_continue_button
          expect(confirm_page.search_results).to have_search_results count: 2
          expect(confirm_page.search_results.name_links).to include '/people/john-doe'
        end
      end
    end

  end
end
