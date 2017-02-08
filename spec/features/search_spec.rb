require 'rails_helper'

feature 'Searching feature', elastic: true do
  extend FeatureFlagSpecHelper

  def create_test_data
    PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk')
    group = create(:group, name: 'HMP Wilsden')
    person = create(:person,
      given_name: 'Jon',
      surname: 'Browne',
      email: 'jon.browne@digital.justice.gov.uk',
      primary_phone_number: '0711111111',
      current_project: 'Digital Prisons')
    create(:membership, person: person, group: group)
  end

  before(:all) do
    clean_up_indexes_and_tables
    create_test_data
    Person.import force: true
    Person.__elasticsearch__.refresh_index!
  end

  after(:all) do
    clean_up_indexes_and_tables
  end

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
    visit home_path
  end

  feature 'for people' do
    scenario 'retrieves the details of matching people' do
      fill_in 'query', with: 'Browne'
      click_button 'Submit search'
      expect(page).to have_title("Search results - #{app_title}")
      within('.breadcrumbs ol') do
        expect(page).to have_text('Search results')
      end
      within('.pagination') do
        expect(page).to have_text(/\d+ result(s)? found/)
      end
      within('.search-box') do
        expect(page).to have_selector("input[value='Browne']")
      end
      expect(page).to have_text('Jon Browne')
      expect(page).to have_text('jon.browne@digital.justice.gov.uk')
      expect(page).to have_text('0711111111')
      expect(page).to have_text('Digital Prisons')
      expect(page).to have_link('add them', href: new_person_path)
    end
  end

  feature 'for groups' do
    scenario 'retrieves the details of the matching group and people in that group' do
      fill_in 'query', with: 'HMP Wilsden'
      click_button 'Submit search'
      expect(page).to have_selector('.details h3', text: 'HMP Wilsden')
      expect(page).to have_selector('.details h3', text: 'Jon Browne')
    end
  end

  feature 'higlighting of search terms' do
    scenario 'highlights individual role group terms' do
      fill_in 'query', with: 'HMP Wilsden'
      click_button 'Submit search'
      within '.result-memberships' do
        expect(page).to have_selector('.es-highlight', text: 'HMP')
        expect(page).to have_selector('.es-highlight', text: 'Wilsden')
      end
    end

    scenario 'highlights individual name terms' do
      fill_in 'query', with: 'Jon Browne'
      click_button 'Submit search'
      within '.result-name' do
        expect(page).to have_selector('.es-highlight', text: 'Browne')
        expect(page).to have_selector('.es-highlight', text: 'Jon')
      end
    end
  end

end
