require 'rails_helper'

feature 'Regression' do
  include PermittedDomainHelper

  let(:login_page) { Pages::Login.new }

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  # scenario 'Gracefully handle a session when the logged in person deletes their profile' do
  #   visit edit_person_path(Person.last)
  #   click_link 'Delete this profile'

  #   expect(login_page).to be_displayed
  # end
end
