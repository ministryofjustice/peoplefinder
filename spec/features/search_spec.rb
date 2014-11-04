require 'rails_helper'

feature 'Search for people', elastic: true do
  describe 'with elasticsearch' do
    let(:community) { create(:community, name: 'Design') }
    let!(:person) {
      create(:person,
        given_name: 'Jon',
        surname: 'Browne',
        email: 'jon.browne@digital.justice.gov.uk',
        primary_phone_number: '0711111111',
        tags: 'Cooking,Eating',
        community: community)
    }

    before do
      create(:department)
      Peoplefinder::Person.import
      Peoplefinder::Person.__elasticsearch__.client.indices.refresh
      omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
    end

    after do
      clean_up_indexes_and_tables
    end

    scenario 'in the most basic form' do
      visit home_path
      fill_in 'query', with: 'Browne'
      click_button 'Submit search'
      expect(page).to have_title("Search results - #{ app_title }")
      within('.breadcrumbs ol') do
        expect(page).to have_text('Search results')
      end
      expect(page).to have_text('Jon Browne')
      expect(page).to have_text('jon.browne@digital.justice.gov.uk')
      expect(page).to have_text('0711111111')
      expect(page).to have_text(community.name)
      expect(page).to have_link('add them', href: new_person_path)
    end

    scenario 'clicking a tag on a profile page' do
      visit person_path(person)
      click_link 'Cooking'
      within('.breadcrumbs ol') do
        expect(page).to have_text('Search results')
      end
      expect(page).to have_text('Jon Browne')
    end

    scenario 'searching by community' do
      visit home_path
      fill_in 'query', with: community.name
      click_button 'Submit search'
      expect(page).to have_title("Search results - #{ app_title }")
      expect(page).to have_text('Jon Browne')
      expect(page).to have_text(community.name)
    end
  end
end
