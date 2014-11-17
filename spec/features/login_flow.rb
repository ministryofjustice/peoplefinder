require 'rails_helper'

feature 'Login flow' do
  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:department) { create(:department) }

  scenario 'When user logs in for the first time, they are prompted to fill in their profile' do
    omni_auth_log_in_as(email)

    page = Pages::EditProfile.new
    expect(page).to be_displayed
  end

  scenario 'When user logs in again, the search page is displayed' do
    create(:person_with_multiple_logins, email: email)

    omni_auth_log_in_as(email)

    page = Pages::Search.new
    expect(page).to be_displayed
  end
end