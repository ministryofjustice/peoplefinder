require 'rails_helper'

feature 'Introduction to the system' do

  let(:user) { create(:user) }

  scenario 'Receiving an introductory email and getting in' do
    send_introduction user
    visit links_in_email(last_email).first
    expect(page).to have_content('Invite people to give you feedback')
  end
end
