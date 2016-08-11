require 'rails_helper'

feature 'Searching feature', elastic: true do
  extend FeatureFlagSpecHelper
  include PermittedDomainHelper

  let!(:group) { create(:group, name: 'Technology') }
  let!(:person) do
    person = create(:person,
      given_name: 'Jon',
      surname: 'Browne',
      email: 'jon.browne@digital.justice.gov.uk',
      primary_phone_number: '0711111111',
      current_project: 'Digital justice')
    create(:membership, person: person, group: group)
    person
  end

  before do
    Person.import
    Person.__elasticsearch__.client.indices.refresh
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
    visit home_path
  end

  after do
    clean_up_indexes_and_tables
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
      expect(page).to have_text('Jon Browne')
      expect(page).to have_text('jon.browne@digital.justice.gov.uk')
      expect(page).to have_text('0711111111')
      expect(page).to have_text('Digital justice')
      expect(page).to have_link('add them', href: new_person_path)
    end
  end

  feature 'for groups' do
    scenario 'retrieves the details of the matching group and people in that group' do
      fill_in 'query', with: 'Technology'
      click_button 'Submit search'
      expect(page).to have_selector('.details h3', text: 'Technology')
      expect(page).to have_selector('.details h3', text: 'Jon Browne')
    end
  end

end
