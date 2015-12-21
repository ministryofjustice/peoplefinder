require 'rails_helper'

feature 'Login flow' do
  include PermittedDomainHelper

  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:department) { create(:department) }
  let(:current_time) { Time.now }

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:profile_page) { Pages::Profile.new }
  let(:search_page) { Pages::Search.new }
  let(:base_page) { Pages::Base.new }

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
