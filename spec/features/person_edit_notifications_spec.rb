require "rails_helper"

describe "Person edit notifications" do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:person) { create(:person, email: "test.user@digital.justice.gov.uk") }

  describe "logged in" do
    before do
      token_log_in_as(person.email)
    end

    it "Creating a person with different email" do
      visit new_person_path

      fill_in "First name", with: "Bob"
      fill_in "Last name", with: "Smith"
      fill_in "Main email", with: "bob.smith@digital.justice.gov.uk"
      expect {
        click_button "Save", match: :first
      }.to change(QueuedNotification, :count).by(1)

      notification = QueuedNotification.last
      expect(notification.current_user_id).to eq person.id
      expect(notification.sent).to be false
      expect(notification.edit_finalised).to be true
      expect(notification.changes_hash["data"]["raw"]).to include(
        "given_name" => [nil, "Bob"],
        "surname" => [nil, "Smith"],
        "location_in_building" => [nil, ""],
        "building" => [nil, ""],
        "city" => [nil, ""],
        "primary_phone_number" => [nil, ""],
        "secondary_phone_number" => [nil, ""],
        "pager_number" => [nil, ""],
        "email" => [nil, "bob.smith@digital.justice.gov.uk"],
        "secondary_email" => [nil, ""],
        "description" => [nil, ""],
        "current_project" => [nil, ""],
        "slug" => [nil, "bob-smith"],
      )
    end

    it "Editing a person with different email" do
      digital = create(:group, name: "Digital")
      person = create(:person, :member_of, team: digital, given_name: "Bob", surname: "Smith", email: "bob.smith@digital.justice.gov.uk")
      visit person_path(person)
      click_edit_profile
      fill_in "Last name", with: "Smelly Pants"
      expect {
        click_button "Save", match: :first
      }.to change(QueuedNotification, :count).by(1)
      expect(QueuedNotification.last.changes_hash["data"]["raw"]["surname"]).to eq(["Smith", "Smelly Pants"])
    end

    it "Editing a person with same email" do
      visit person_path(person)
      click_edit_profile
      fill_in "Last name", with: "Smelly Pants"
      expect {
        click_button "Save", match: :first
      }.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end

  describe "accessing via token link" do
    let(:bob) { create(:person, email: "bob@digital.justice.gov.uk", surname: "bob") }

    it "Verifying the link to bob that is render in the emails" do
      visit token_url(Token.for_person(bob))

      within("h1") do
        expect(page).to have_text("bob")
      end
    end

    it "tells user that their profile is not complete" do
      bob.update_attribute(:given_name, nil) # rubocop:disable Rails/SkipsModelValidations
      visit token_url(Token.for_person(bob))

      expect(page).to have_text("You need to create or update a People Finder account to finish signing in")
    end
  end
end
