require 'rails_helper'

feature "Authentication" do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:gplus] = OmniAuth::AuthHash.new({
      provider: 'gplus',
      info: {
        email: 'test.user@digital.justice.gov.uk'
      }
    })
  end

  scenario "Logging in and out" do
    visit '/'
    expect(page).to have_text("Please log in to continue")

    click_link "log in"
    expect(page).to have_text("Logged in as test.user@digital.justice.gov.uk")

    click_link "Log out"
    expect(page).to have_text("Please log in to continue")
  end
end
