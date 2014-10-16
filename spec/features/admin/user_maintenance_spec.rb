require 'rails_helper'

feature 'Administrator maintaining users' do
  let(:user) { create(:admin_user, name: 'Bob') }

  before do
    log_in_as user
  end

  scenario 'Creating users with hierarchy' do
    visit admin_path

    click_link 'Manage users'

    click_link 'New user'
    fill_in 'Name', with: 'Alice'
    fill_in 'Email', with: 'alice@example.com'
    check 'Participant'
    click_button 'Create'

    click_link 'New user'
    fill_in 'Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    select 'Alice', from: 'Manager'
    check 'Participant'
    click_button 'Create'

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first
    expect(bob.manager).to eql(alice)
  end

  scenario 'Not deleting myself' do
    visit admin_users_path
    expect(page).to have_no_button('Delete')
  end

  scenario 'Deleting a user' do
    create(:user)

    visit admin_users_path

    expect {
      click_button 'Delete'
    }.to change(User, :count).by(-1)
  end
end
