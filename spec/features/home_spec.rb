require 'rails_helper'

feature 'Home page' do
  before do
    create(:department)
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
    visit '/'
  end

  scenario 'Viewing the page' do
    within('h1') { expect(page).to have_text('Welcome to People Finder') }
    expect(page).to have_css('h2', text: 'Search')
    expect(page).to have_css('input#query')
  end
end
