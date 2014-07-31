require 'rails_helper'

feature "Authentication" do
  scenario "Logging in and out for a registered user" do
    given_i_have_an_account
    when_i_visit_the_home_page
    and_i_enter_my_email
    and_i_enter_my_password
    and_i_click 'Log in'
    then_i_should_be_logged_in
    when_i_click 'Log out'
    then_i_should_not_be_logged_in
  end

  scenario "Failing to log in with the wrong password" do
    given_i_have_an_account
    when_i_visit_the_home_page
    and_i_enter_my_email
    and_i_enter_an_arbitrary_password
    and_i_click 'Log in'
    then_i_should_not_be_logged_in
    and_i_should_see_an_incorrect_password_message
  end

  scenario "Failing to log in with a completely wrong email address" do
    given_i_have_an_account
    when_i_visit_the_home_page
    and_i_enter_an_unregistered_email
    and_i_enter_an_arbitrary_password
    and_i_click 'Log in'
    then_i_should_not_be_logged_in
    and_i_should_see_an_incorrect_password_message
  end

  def then_i_should_be_logged_in
    expect(page).to have_text("Logged in as #{state[:me]}")
  end

  def then_i_should_not_be_logged_in
    expect(page).to have_text("Please log in to continue")
  end

  def and_i_should_see_an_incorrect_password_message
    expect(page).to have_text("incorrect")
  end
end
