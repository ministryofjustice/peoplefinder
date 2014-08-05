require 'rails_helper'

feature 'Home page' do
  before do
    create(:group, name: 'Ministry of Justice', parent: nil)
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Viewing the page' do
    within('h1') { expect(page).to have_text('Ministry of Justice people finder') }
  end
end
