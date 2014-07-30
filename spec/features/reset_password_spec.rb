require 'rails_helper'

feature "Reset users password" do

  before do
    given_i_have_an_account
    and_i_have_no_emails
  end

  scenario "Resetting my password" do
    when_i_visit_the_home_page
    and_i_follow_the_forgotten_password_link
    and_i_enter_my_email
    and_i_click 'Submit'
    then_i_should_see_a_password_reset_message

    when_i_follow_the_emailed_reset_link
    and_i_enter_a_new_password
    and_i_click 'Submit'
    then_i_should_have_a_new_password
  end

  scenario "An unregistered user attempting to reset their password" do
    when_i_visit_the_home_page
    and_i_follow_the_forgotten_password_link
    and_i_enter_an_unregistered_email
    and_i_click 'Submit'
    then_i_should_see_a_not_found_message
    and_no_email_should_be_sent
  end

  scenario "Attempting to subvert the reset token" do
    when_i_visit_the_reset_page_with_a_forged_token
    then_i_should_see_an_invalid_token_message
    and_no_email_should_be_sent
  end

  def when_i_visit_the_home_page
    visit '/'
  end

  def when_i_visit_the_reset_page_with_a_forged_token
    visit passwords_path(token: SecureRandom.urlsafe_base64)
  end

  def and_i_follow_the_forgotten_password_link
    click_link 'Forgotten your password?'
  end

  def then_i_should_see_a_password_reset_message
    expect(page).to have_text( 'An email with a link to reset your password has been sent')
  end

  def then_i_should_see_a_not_found_message
    expect(page).to have_text("An account with that email address can’t be found")
  end

  def when_i_follow_the_emailed_reset_link
    open_email(state[:me].email)
    current_email.click_link('Password reset link')
  end

  def when_i_reset_my_password
    when_i_visit_the_home_page
    and_i_follow_the_forgotten_password_link
    and_i_enter_my_email
    and_i_click_submit
  end
end
