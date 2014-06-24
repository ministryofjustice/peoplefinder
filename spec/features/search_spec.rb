require 'rails_helper'

feature 'Search for people' do
  before(:all) do
    Person.delete_all
    Person.create!(surname: 'Browne')
    Person.create!(surname: 'Browning')
    Person.import
    sleep 1
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  after(:all) do
    Person.__elasticsearch__.create_index! index: Person.index_name, force: true
  end

  scenario 'by surname' do
    visit root_path
    fill_in 'query', with: 'Browne'
    click_button 'Search'

    expect(page).to have_text('Browne')
    expect(page).to_not have_text('Browning')
  end
end