require 'rails_helper'

feature 'Home page' do
  before do
    create(:department)
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
    visit '/'
  end

  scenario 'Viewing the page' do
    within('h1') { expect(page).to have_text('Ministry of Justice people finder') }
    expect(page).to have_text('Search the people finder')
    expect(page).to have_css('input#query')
    expect(page).to have_link('Add new profile', href: new_person_path)
    expect(page).to have_link('Ministry of Justice', href: groups_path)
  end
end
