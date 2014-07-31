require 'rails_helper'

feature "Inviting a new user to the system" do

  before do
    given_i_have_an_account
    and_i_have_no_emails
  end

  scenario "Being invited and setting a password" do
    when_i_am_invited
    then_i_should_receive_an_invitation_email
    when_i_follow_the_link_to_complete_my_registration
    and_i_enter_a_new_password
    and_i_click 'Finish'
    then_i_should_have_a_new_password
    and_i_should_see_a_registration_message
  end

  scenario "Attempting to subvert the token" do
    when_i_visit_the_registration_page_with_a_forged_token
    then_i_should_see_an_invalid_token_message
    and_no_email_should_be_sent
  end

  def when_i_am_invited
    state[:me].invite!
  end

  def when_i_visit_the_registration_page_with_a_forged_token
    visit new_registration_path(token: SecureRandom.hex)
  end

  def then_i_should_receive_an_invitation_email
    open_email(state[:me].email)
    expect(current_email).to have_text(state[:me].name)
    expect(current_email).to have_text("You've been invited to the SCS Appraisal system")
  end

  def when_i_follow_the_link_to_complete_my_registration
    current_email.click_link('Complete your registration')
  end

  def and_i_should_see_a_registration_message
    expect(page).to have_text('Registration is now complete')
  end
end
