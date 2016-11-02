require 'rails_helper'

feature 'Login flow' do
  include PermittedDomainHelper

  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:department) { create(:department) }
  let(:current_time) { Time.now }

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:edit_group_page) { Pages::EditGroup.new}
  let(:new_profile_page) { Pages::NewProfile.new }
  let(:profile_page) { Pages::Profile.new }
  let(:login_page) { Pages::Login.new }
  let(:search_page) { Pages::Search.new }
  let(:base_page) { Pages::Base.new }

  context 'Choosing to login' do
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

  context 'Unlogged-in User prompted to login' do

    context 'when creating a profile and I have my own profile' do
      scenario 'redirects to new profile page' do
        create(:person, email: email, created_at: 1.minute.ago)
        visit new_person_path
        expect(login_page).to be_displayed
        token_log_in_as(email)
        expect(new_profile_page).to be_displayed
        expect(profile_page.body).to include 'You are creating a profile'
      end
    end

    context 'when creating a profile without having my own profile' do
      scenario 'redirects to their own just created profile page and flashes a notice' do
        visit new_person_path
        expect(login_page).to be_displayed
        token_log_in_as(email)
        expect(profile_page).to be_displayed
        expect(profile_page.body).to include 'Your profile did not exist so we created it for you.'
      end
    end

    context 'when editing a team without having my own profile' do
      let(:group) { create :group }
      scenario 'flashes a notice that their own profile was just created' do
        visit edit_group_path group
        expect(login_page).to be_displayed
        token_log_in_as(email)
        expect(edit_group_page.current_url).to eql page.current_url
        expect(edit_group_page.body).to include 'Your profile did not exist so we created it for you.'
      end
    end

    context 'when editing a profile without having my own profile' do
      let(:person) { create :person }
      scenario 'flashes a notice that their own profile was just created' do
        visit edit_person_path person
        expect(login_page).to be_displayed
        token_log_in_as(email)
        expect(edit_group_page.current_url).to eql page.current_url
        expect(edit_profile_page.body).to include 'Your profile did not exist so we created it for you.'
      end
    end

  end

end
