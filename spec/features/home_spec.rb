require 'rails_helper'

feature 'Home page' do
  include PermittedDomainHelper

  let(:home_page) { Pages::Home.new }

  before do
    create(:department)
  end

  context 'page structure' do
    before do
      mock_readonly_user
      visit '/'
    end

    it 'is all there' do
      expect(home_page).to have_page_title
      expect(home_page).to have_search_form
      expect(home_page.page_title).to have_text('Welcome to People Finder')
    end
  end

  context 'for a regular user' do
    before do
      omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
      visit '/'
    end

    scenario 'Can view the page' do
      expect(home_page).to be_displayed
      expect(home_page).to be_all_there
    end
  end

  context 'for the readonly user' do
    before do
      mock_readonly_user
      visit '/'
    end

    scenario 'Can view the page' do
      expect(home_page).to be_displayed
      expect(home_page).to be_all_there
    end
  end
end
