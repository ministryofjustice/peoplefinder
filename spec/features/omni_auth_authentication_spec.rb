require 'rails_helper'

feature 'OmniAuth Authentication' do
  include PermittedDomainHelper

  let(:group) { create(:group) }

  let(:login_page) { Pages::Login.new }
  let(:profile_page) { Pages::Profile.new }
  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:group_page) { Pages::Group.new }

  before do
    OmniAuth.config.test_mode = true
  end

  scenario 'Logging in and out' do
    OmniAuth.config.mock_auth[:gplus] = valid_user

    visit '/'
    expect(login_page).to be_displayed
    expect(page).to have_title("Log in - #{app_title}")

    click_link 'Log in using Google+'
    expect(page).to have_text('Signed in as John Doe')

    click_link 'Sign out'
    expect(login_page).to be_displayed
  end

  scenario 'Log in failure' do
    OmniAuth.config.mock_auth[:gplus] = invalid_user

    visit '/'
    expect(login_page).to be_displayed

    click_link 'Log in using Google+'
    expect(page).to have_title("Login failure - #{app_title}")
    expect(page).to have_text(/log in with an MoJ email address/)

    click_link 'Return to the log in screen'
    expect(login_page).to be_displayed
  end

  scenario 'Non existent users are redirected to their new profiles edit page after logging in' do
    OmniAuth.config.mock_auth[:gplus] = valid_user
    group = create(:group)
    visit group_path(group)
    click_link 'Log in using Google+'
    expect(edit_profile_page).to be_displayed
  end

  scenario 'Existing users are redirected to their desired path after logging in' do
    create(:person, email: valid_user[:info][:email])
    OmniAuth.config.mock_auth[:gplus] = valid_user
    visit group_path(group)
    click_link 'Log in using Google+'
    expect(group_page).to be_displayed
  end
end

def invalid_user
  OmniAuth::AuthHash.new(
    provider: 'gplus',
    info: {
      email: 'test.user@example.com',
      first_name: 'John',
      last_name: 'Doe',
      name: 'John Doe'
    }
  )
end

def valid_user
  OmniAuth::AuthHash.new(
    provider: 'gplus',
    info: {
      email: 'test.user@digital.justice.gov.uk',
      first_name: 'John',
      last_name: 'Doe',
      name: 'John Doe'
    }
  )
end
