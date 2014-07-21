require 'rails_helper'

feature "Authentication" do

  let(:valid_registered_user){ create(:user, name: 'John Doe', password: '12345678')}

  scenario "Logging in and out for a registered user" do

    visit '/'
    expect(page).to have_text("Please log in to continue")

    fill_in 'auth_key', with: valid_registered_user.email
    fill_in 'password', with: '12345678'
    click_button 'Login'
    expect(page).to have_text("Logged in as John Doe")

    click_link "Log out"
    expect(page).to have_text("Please log in to continue")
  end

  scenario 'Log in failure for a registered user with invalid password' do
    visit '/'
    expect(page).to have_text("Please log in to continue")

    fill_in 'auth_key', with: valid_registered_user.email
    fill_in 'password', with: 'this is an incorrect password wibble'
    click_button 'Login'

    expect(page).to_not have_text("Logged in as John Doe")
    expect(page).to have_css('h1', 'Please log in to continue ')
  end

  scenario "Login failure for someone who isn't registered with the app" do
    visit '/'
    expect(page).to have_text("Please log in to continue")

    fill_in 'auth_key', with: 'lord_of_not_registered@example.com'
    fill_in 'password', with: 'this is an incorrect password wibble'
    click_button 'Login'

    expect(page).to_not have_text("Logged in as John Doe")
    expect(page).to have_css('h1', 'Please log in to continue ')
  end



end
