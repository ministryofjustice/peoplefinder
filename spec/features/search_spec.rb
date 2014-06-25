require 'rails_helper'

feature 'Search for people' do
  describe 'with elasticsearch', elastic: true do
    before(:all) do
      Person.delete_all
      Person.create!(given_name: 'Jon', surname: 'Browne')
      Person.create!(given_name: 'Jill', surname: 'Browning')
      Person.import
      sleep 1
    end

    before(:each) do
      log_in_as 'test.user@digital.justice.gov.uk'
    end

    after(:all) do
      Person.__elasticsearch__.create_index! index: Person.index_name, force: true
    end

    scenario 'by surname' do
      visit root_path
      fill_in 'query', with: 'Browne'
      click_button 'Search'

      expect(page).to have_text('Jon Browne')
      expect(page).to_not have_text('Jill Browning')
    end

    scenario 'by given_name and surname' do
      visit root_path
      fill_in 'query', with: 'Jill Browning'
      click_button 'Search'

      expect(page).to_not have_text('Jon Browne')
      expect(page).to have_text('Jill Browning')
    end
  end
end