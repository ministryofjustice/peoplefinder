require 'rails_helper'

feature 'Login flow' do
  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:department) { create(:department) }
  let(:current_time) { Time.now }

  before { Timecop.freeze(current_time) }
  after { Timecop.return }

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

  scenario 'Login counter is updated every time user logs in' do
    login_count = 3
    person = create(:person_with_multiple_logins, email: email, login_count: login_count)

    omni_auth_log_in_as(email)

    person.reload
    expect(person.login_count).to eql(4)
  end

  scenario 'Last login date is updated every time user logs in' do
    person = create(:person_with_multiple_logins, email: email, last_login_at: 5.days.ago)

    omni_auth_log_in_as(email)

    person.reload
    expect(person.last_login_at).to eql(current_time)
  end
end
