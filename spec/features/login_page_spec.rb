require "rails_helper"

describe "Login page" do
  include PermittedDomainHelper

  let(:login_page) { Pages::Login.new }
  let(:token_created_page) { Pages::TokenCreated.new }

  context "with a user from outside the network" do
    it "Is presented with standard login page and copy" do
      visit "/"

      expect(login_page).to be_displayed
      expect(login_page.description).to have_text("We will email you a secure link so you can log in to People Finder and create or edit profiles.")
    end
  end

  context "with a user from inside the network" do
    before do
      mock_readonly_user
    end

    it "Is presented with standard login page and copy if they decide to login" do
      visit "/sessions/new"

      expect(login_page).to be_displayed
      expect(login_page.description).to have_text("We will email you a secure link so you can log in to People Finder and create or edit profiles.")
    end

    it "Is presented with special login page and copy if they are forced to login to make changes" do
      person = create(:person)

      visit person_path(person)
      click_edit_profile

      expect(login_page).to be_displayed
      expect(login_page.description).to have_text("For security reasons, you have to be logged in to People Finder to make any changes.")
      expect(login_page.description).to have_text("We will email you a secure link so you can log in.")

      login_page.email.set(person.email)
      login_page.request_button.click

      expect(token_created_page).to be_displayed
      expect(token_created_page.info).to have_text("When it arrives, click on the link (which is active for 1 day). This will log you in to People Finder and enable you to make any changes.")
    end
  end
end
