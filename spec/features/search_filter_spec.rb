require 'rails_helper'

feature 'Search results page' do
  subject(:search_page) { Pages::Search.new }

  def create_test_data
    clean_up_indexes_and_tables
    create(:permitted_domain)
    create(:group, name: 'HMP Browne')
    create(:group, name: 'SMT Browne')
    create(:person, given_name: 'Jim', surname: 'Browne')
    create(:person, given_name: 'Jon', surname: 'Browne')
    Person.import force: true
    Person.__elasticsearch__.refresh_index!
  end

  before do
    create_test_data
    mock_readonly_user
    visit '/'
  end

  feature 'structure' do
    before { click_button 'Search' }

    it { is_expected.to be_displayed }

    it 'has search bar' do
      is_expected.to have_search_form
      expect(search_page.search_form).to be_all_there
    end

    it 'has search result summary' do
      is_expected.to have_search_result_summary
    end

    it 'has search filter sidebar' do
      is_expected.to have_search_filters_form
      expect(search_page.search_filters_form).to be_all_there
    end

    it 'has search results' do
      is_expected.to have_search_results
    end

    it 'has search footer' do
      is_expected.to have_search_footer
      expect(search_page.search_footer).to be_all_there
    end
  end

  feature 'filtering' do
    before do
      fill_in 'query', with: 'browne'
      click_button 'Search'
    end

    scenario 'defaults to searching people and teams' do
      expect(search_page.search_form.search_field.value).to eq 'browne'
      expect(search_page.search_result_summary).to have_text('people (2) and teams (2)')
      expect(search_page.search_results).to have_people_results count: 2
      expect(search_page.search_results).to have_team_results count: 2
      expect(search_page.search_results.people_result_names).to include 'Jon Browne', 'Jim Browne'
      expect(search_page.search_results.team_result_names).to include 'HMP Browne', 'SMT Browne'
    end

    scenario 'on people', js: true do
      uncheck 'Teams'
      expect(search_page.search_result_summary).to have_text('2 results found from people')
      expect(search_page.search_results).to have_people_results count: 2
      expect(search_page.search_results).to have_team_results count: 0
      expect(search_page.search_results.people_result_names).to include 'Jon Browne', 'Jim Browne'
    end

    scenario 'on teams', js: true do
      uncheck 'People'
      expect(search_page.search_result_summary).to have_text('browne not found - 2 similar results from teams')
      expect(search_page.search_results).to have_people_results count: 0
      expect(search_page.search_results).to have_team_results count: 2
      expect(search_page.search_results.team_result_names).to include 'HMP Browne', 'SMT Browne'
    end

    scenario 'on none', js: true do
      uncheck 'People'
      uncheck 'Teams'
      expect(search_page.search_result_summary).to have_text('browne not found - 0 similar results')
      expect(search_page.search_results).to have_people_results count: 0
      expect(search_page.search_results).to have_team_results count: 0
    end
  end

end
