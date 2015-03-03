require 'rails_helper'

feature 'Make a suggestion about a profile', javascript: true do
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:profile) { create(:person, email: 'example@digital.justice.gov.uk') }

  before do
    omni_auth_log_in_as(person.email)
  end

  scenario 'Ask a person to complete missing fields' do
    visit person_path(profile)
    click_link 'Help improve this profile'
  end

end
