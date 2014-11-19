require 'rails_helper'

feature 'Login flow' do
  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:department) { create(:department) }
  let(:current_time) { Time.now }

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:search_page) { Pages::Search.new }

  scenario 'When user logs in for the first time, they are prompted to fill in their profile' do
    omni_auth_log_in_as(email)

    expect(edit_profile_page).to be_displayed
  end

  scenario 'User is prompted to update their profile every 5 logins it their profile is incomplete' do
    login_count = (rand(1..10) * 5) - 1
    create(:person_with_multiple_logins, email: email, login_count: login_count)

    omni_auth_log_in_as(email)

    expect(edit_profile_page).to be_displayed
  end

  scenario 'When user logs in other than 1st or every 5th time, the search page is displayed' do
    login_count = (rand(0..10) * 5 + rand(1..4)) - 1
    create(:person_with_multiple_logins, email: email, login_count: login_count)

    omni_auth_log_in_as(email)

    expect(search_page).to be_displayed
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

    Timecop.freeze(current_time) do
      omni_auth_log_in_as(email)
    end

    person.reload
    expect(person.last_login_at.utc.to_i).to eql(current_time.utc.to_i)
  end
end
