require 'rails_helper'

feature 'Administrator authentication' do

  let(:password) { generate(:password) }
  let(:user) { create(:admin_user, name: 'Bob') }
  let(:identity) { create(:identity, password: password, user: user) }

  scenario 'Logging in' do
    visit admin_path
    expect(current_path).to eql(new_login_path)

    log_in identity.username, password

    expect(current_path).to eql(admin_path)
    expect(page).to have_text('Logged in as Bob')
  end

  scenario 'Failing to log in' do
    visit admin_path
    expect(current_path).to eql(new_login_path)

    log_in identity.username, 'WRONG'

    expect(current_path).to eql(login_path)
    expect(page).not_to have_text('Logged in as')
  end

  scenario 'Logging out' do
    visit admin_path
    log_in identity.username, password
    click_button 'Log out'
    expect(current_path).to eql(root_path)
    expect(page).not_to have_text('Logged in as')
  end
end
