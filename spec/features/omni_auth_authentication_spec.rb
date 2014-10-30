require 'rails_helper'

feature 'OmniAuth Authentication' do
  before do
    OmniAuth.config.test_mode = true
  end

  scenario 'Logging in and out' do
    OmniAuth.config.mock_auth[:gplus] = valid_user

    visit '/'
    expect(page).to have_title("Log in - #{ app_title }")
    expect(page).to have_text('Log in to the people finder')

    click_link 'Log in'
    expect(page).to have_text('Logged in as John Doe')

    click_link 'Log out'
    expect(page).to have_text('Log in to the people finder')
  end

  scenario 'Log in failure' do
    OmniAuth.config.mock_auth[:gplus] = invalid_user

    visit '/'
    expect(page).to have_text('Log in to the people finder')

    click_link 'Log in'
    expect(page).to have_title("Login failure - #{ app_title }")
    expect(page).to have_text(/log in with a MOJ or GDS email address/)

    click_link 'Return to the log in screen'
    expect(page).to have_text('Log in to the people finder')
  end

  scenario 'Being redirected to desired path after logging in' do
    OmniAuth.config.mock_auth[:gplus] = valid_user

    group = create(:group)
    path = group_path(group)

    visit path
    click_link 'Log in'

    expect(current_path).to eql(path)
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
