require 'rails_helper'

feature 'User maintenance' do

  let(:password) { generate(:password) }
  let(:user) { create(:admin_user, name: 'Bob') }
  let(:identity) { create(:identity, password: password, user: user) }

  scenario 'Creating and editing users' do
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
end
