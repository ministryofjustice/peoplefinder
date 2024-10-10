require "rails_helper"

RSpec.describe SuggestionMailer do
  include PermittedDomainHelper

  let(:suggester) { create(:person, email: "suggester@digital.justice.gov.uk") }
  let(:person)    { create(:person, email: "person@digital.justice.gov.uk") }
  let(:admin)     { create(:person, email: "admin@digital.justice.gov.uk") }

  def expect_mail_body_text(text)
    %w[plain html].each do |part_type|
      expect(get_message_part(mail, part_type)).to have_text(text)
    end
  end

  describe ".person_email" do
    let(:missing_fields_info) { "You're missing some details" }
    let(:suggestion_hash) do
      {
        missing_fields: true,
        missing_fields_info:,
        incorrect_fields: true,
        incorrect_first_name: true,
        incorrect_last_name: true,
        incorrect_location_of_work: true,
      }
    end

    let(:mail) { described_class.person_email(person, suggester, suggestion_hash).deliver_now }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "481a02b5-5783-453a-87c4-d7ec1d55842e"
    end

    it "is sent to the profile email" do
      expect(mail.to).to include(person.email)
    end

    it "sets personalisation options" do
      expect(mail.govuk_notify_personalisation[:suggester_name]).to eq suggester.name
      expect(mail.govuk_notify_personalisation[:suggestion_missing_fields]).to eq missing_fields_info
      expect(mail.govuk_notify_personalisation[:suggestion_incorrect_fields]).to eq "First name, Last name, Location of work"
    end
  end

  describe ".team_admin_email" do
    let(:inappropriate_content_info) { "A bit saucy" }
    let(:person_left_info) { "Person left last year" }
    let(:suggestion_hash) do
      {
        duplicate_profile: true,
        inappropriate_content: true,
        inappropriate_content_info:,
        person_left: true,
        person_left_info:,
      }
    end

    let(:mail) do
      described_class.team_admin_email(
        person,
        suggester,
        suggestion_hash,
        admin,
      ).deliver_now
    end

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "48109d13-7b60-44b8-8dc1-3bded70468cc"
    end

    it "is sent to the provided team admin" do
      expect(mail.to).to include(admin.email)
    end

    it "contains the first name of the team admin" do
      expect(mail.govuk_notify_personalisation[:admin_name]).to eq admin.given_name
    end

    it "contains the name of the suggester" do
      expect(mail.govuk_notify_personalisation[:suggester_name]).to eq suggester.name
    end

    it "contains the name of the person whose profile it concerns" do
      expect(mail.govuk_notify_personalisation[:person_name]).to eq person.name
    end

    it "contains a link to the profile it concerns" do
      expect(mail.govuk_notify_personalisation[:person_url]).to eq person_url(person)
    end

    describe "when duplicate profile suggested" do
      it "contains duplicate_profile as true" do
        expect(mail.govuk_notify_personalisation[:duplicate_profile]).to be true
      end
    end

    describe "when inappropriate content suggested" do
      it "contains inappropriate_content as true" do
        expect(mail.govuk_notify_personalisation[:inappropriate_content]).to be true
      end

      it "contains inappropriate content info" do
        expect(mail.govuk_notify_personalisation[:inappropriate_content_info]).to eq "They provided the following information about inappropriate content: #{inappropriate_content_info}"
      end
    end

    describe "when inappropriate content not suggested" do
      before do
        suggestion_hash[:inappropriate_content_info] = nil
      end

      it "contains empty inappropriate content info" do
        expect(mail.govuk_notify_personalisation[:inappropriate_content_info]).to eq ""
      end
    end

    describe "when suggested that person left" do
      it "contains person_left as true" do
        expect(mail.govuk_notify_personalisation[:person_left]).to be true
      end

      it "contains person left info" do
        expect(mail.govuk_notify_personalisation[:person_left_info]).to eq "They provided the following information about the person leaving: #{person_left_info}"
      end
    end

    describe "when person left not suggested" do
      before do
        suggestion_hash[:person_left_info] = nil
      end

      it "contains empty person left info" do
        expect(mail.govuk_notify_personalisation[:person_left_info]).to eq ""
      end
    end
  end
end
