require 'rails_helper'

feature 'Administration password reset' do
  let(:password) { generate(:password) }
  let(:user) { create(:admin_user, name: 'Bob') }
  let(:identity) { create(:identity, password: password, user: user) }

  scenario 'With valid credentials' do
    visit admin_path
    click_link 'Forgot password'

    expect(current_path).to eq(new_admin_password_reset_path)

    fill_in 'Email', with: user.email
    click_button 'Send password reset link'

    expect(current_path).to eq new_login_path
    expect(page).to have_text('Password reset link sent')
  end
end
