require 'rails_helper'

feature 'Regression' do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Gracefully handle a session when the logged in person deletes their profile' do
    visit edit_person_path(Peoplefinder::Person.last)
    click_link 'Delete this profile'
    expect(page).to have_text('Log in to the people finder')
  end
end
