require 'rails_helper'

feature "Authentication" do
  before do
    OmniAuth.config.test_mode = true
  end

  scenario "Logging in and out" do
    OmniAuth.config.mock_auth[:gplus] = valid_user

    visit '/'
    expect(page).to have_text("Please log in to continue")

    click_link "log in"
    expect(page).to have_text("Logged in as test.user@digital.justice.gov.uk")

    click_link "Log out"
    expect(page).to have_text("Please log in to continue")
  end

  scenario 'Log in failure' do
    OmniAuth.config.mock_auth[:gplus] = invalid_user

    visit '/'
    expect(page).to have_text("Please log in to continue")

    click_link "log in"
    expect(page).to have_text(/log in with an MOJ DS or GDS account/)
  end
end

def invalid_user
  OmniAuth::AuthHash.new({
    provider: 'gplus',
    info: {
      email: 'test.user@example.com'
    }
  })
end

def valid_user
  OmniAuth::AuthHash.new({
    provider: 'gplus',
    info: {
      email: 'test.user@digital.justice.gov.uk'
    }
  })
end
