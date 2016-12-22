require 'rails_helper'

feature 'Home page' do
  include PermittedDomainHelper

  context 'for a regular user' do
    before do
      create(:department)
      omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
      visit '/'
    end

    scenario 'Viewing the page' do
      within('h1') { expect(page).to have_text('Welcome to People Finder') }
      expect(page).to have_css('input#query')
    end
  end

  context 'for the readonly user' do
    before do
      create(:department)
      mock_readonly_user
      visit '/'
    end

    scenario 'Viewing the page' do
      within('h1') { expect(page).to have_text('Welcome to People Finder') }
      expect(page).to have_css('input#query')
    end
  end
end
