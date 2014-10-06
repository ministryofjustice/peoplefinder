require 'rails_helper'

feature 'Administration' do
  let(:password) { generate(:password) }
  let(:user) { create(:admin_user, name: 'Bob') }
  let(:identity) { create(:identity, password: password, user: user) }

  scenario 'Start password reset' do
    visit admin_path
    click_link 'Forgot password'
    expect(current_path).to eq(new_admin_password_reset_path)
  end
end
