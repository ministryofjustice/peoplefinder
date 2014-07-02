require 'rails_helper'

feature 'Search for people', elastic: true do
  describe 'with elasticsearch' do
    before do
      Person.create!(given_name: 'Jon', surname: 'Browne')
      Person.import
      sleep 1
      log_in_as 'test.user@digital.justice.gov.uk'
    end

    after do
      clean_up_indexes_and_tables
    end

    scenario 'in the most basic form' do
      visit root_path
      fill_in 'query', with: 'Browne'
      click_button 'Search'

      expect(page).to have_text('Jon Browne')
    end
  end
end
