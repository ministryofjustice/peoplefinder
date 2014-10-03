require 'rails_helper'

feature 'Administration' do

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

  scenario 'Uploading a CSV' do
    visit admin_path
    log_in identity.username, password

    expect {
      attach_file 'File', Rails.root.join('spec', 'data', 'users.csv')
      click_button 'Upload'
    }.to change(User, :count).by(3)
    expect(current_path).to eql(admin_path)
    expect(page).to have_text('Users uploaded successfully')
  end

  scenario 'Uploading an empty file' do
    visit admin_path
    log_in identity.username, password

    click_button 'Upload'

    expect(current_path).to eql(admin_path)
    expect(page).to have_text('No users were uploaded')
  end

  scenario 'Editing users' do
    visit admin_path
    log_in identity.username, password

    click_link 'Manage users'

    click_link 'New user'
    fill_in 'Name', with: 'Alice'
    fill_in 'Email', with: 'alice@example.com'
    check 'Participant'
    click_button 'Create User'

    click_link 'New user'
    fill_in 'Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    select 'Alice', from: 'Manager'
    check 'Participant'
    click_button 'Create User'

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first
    expect(bob.manager).to eql(alice)
  end

  def log_in(username, password)
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    click_button 'Log in'
  end
end
