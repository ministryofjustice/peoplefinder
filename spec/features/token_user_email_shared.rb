require "rails_helper"

RSpec.shared_examples "it received a valid request from" do
  it "and sends the email" do
    visit "/"
    fill_in "token_user_email", with: email
    click_button "Request link"
    expect(page).to have_text("We’re just emailing you a link to access People Finder")
  end
end
