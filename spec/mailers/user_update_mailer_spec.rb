require "rails_helper"

describe UserUpdateMailer do
  include PermittedDomainHelper

  let(:instigator) { create(:person, email: "instigator.user@digital.justice.gov.uk") }
  let(:person) { create(:person, email: "test.user@digital.justice.gov.uk", profile_photo_id: 1, description: "old info") }

  describe ".new_profile_email" do
    subject(:mail) { described_class.new_profile_email(person, instigator.email).deliver_now }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "9bc86cfd-588e-4318-8653-d1544ceeab8b"
    end

    it "includes the person name" do
      expect(mail.govuk_notify_personalisation[:name]).to eq person.given_name
    end

    it "includes the added_by" do
      expect(mail.govuk_notify_personalisation[:added_by]).to include instigator.email
    end

    it "includes the person show url" do
      expect(mail.govuk_notify_personalisation[:profile_url]).to eq person_url(person)
    end
  end

  describe ".updated_profile_email" do
    subject(:mail) do
      described_class.updated_profile_email(person, serialized_changes, instigator.email).deliver_now
    end

    let!(:hr) { create(:group, name: "Human Resources") }
    let(:hr_membership) { create(:membership, person:, group: hr, role: "Administrative Officer") }
    let!(:ds) { create(:group, name: "Digital Services") }
    let!(:csg) { create(:group, name: "Corporate Services Group") }

    let(:changes_presenter) { ProfileChangesPresenter.new(person.all_changes) }
    let(:serialized_changes) { changes_presenter.serialize }

    let(:mass_assignment_params) do
      {
        email: "changed.user@digital.justice.gov.uk",
        works_monday: false,
        works_saturday: true,
        profile_photo_id: 2,
        description: "changed info",
        memberships_attributes: {
          "0" => {
            role: "Lead Developer",
            group_id: ds.id,
            leader: true,
            subscribed: false,
          },
          "1" => {
            role: "Product Manager",
            group_id: csg.id,
            leader: false,
            subscribed: true,
          },
          "2" => {
            id: hr_membership.id,
            group_id: hr.id,
            role: "Chief Executive Officer",
            leader: true,
            subscribed: false,
          },
          "3" => {
            id: person.memberships.find_by(group_id: Group.department).id,
            _destroy: "1",
          },
        },
      }
    end

    let(:team_reassignment) do
      {
        memberships_attributes: {
          "2" => {
            id: hr_membership.id,
            group_id: ds.id,
            role: "Chief Executive Officer",
            leader: true,
            subscribed: false,
          },
        },
      }
    end

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "df798a71-5ab9-437b-88e2-57d3f2011585"
    end

    it "deserializes changes to create presenter objects" do
      profile_changes_presenter = double(ProfileChangesPresenter).as_null_object
      expect(ProfileChangesPresenter).to receive(:deserialize)
        .with(serialized_changes)
        .and_return(profile_changes_presenter)
      mail
    end

    it "includes the person show url" do
      expect(mail.govuk_notify_personalisation[:profile_url]).to eq person_url(person)
    end

    context "with recipients" do
      it "emails the changed person" do
        expect(mail.to).to include "test.user@digital.justice.gov.uk"
      end

      it "when email changed it emails the changed person at new address and cc's old address" do
        person.assign_attributes(email: "changed.user@digital.justice.gov.uk")
        person.save!
        expect(mail.to).to include "changed.user@digital.justice.gov.uk"
        expect(mail.to).to include "test.user@digital.justice.gov.uk"
      end
    end

    context "with mail content" do
      before do
        # mock controller mass assignment behaviour for applying changes
        person.reload
        person.assign_attributes(mass_assignment_params)
        person.save!
      end

      it "includes team membership additions" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Added you to the Digital Services team as Lead Developer. You are a leader of the team")
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Added you to the Corporate Services Group team as Product Manager")
      end

      it "includes team membership removals" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Removed you from the Ministry of Justice team")
      end

      it "includes team membership modifications" do
        person.assign_attributes(team_reassignment)
        person.save!
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Changed your membership of the Human Resources team to the Digital Services team")
      end

      it "includes team membership role modifications" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Changed your role from Administrative Officer to Chief Executive Officer in the Human Resources team")
      end

      it "includes team membership leadership modifications" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Made you leader of the Human Resources team")
      end

      it "includes team membership subscription modifications" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Changed your notification settings so you don't get notifications if changes are made to the Human Resources team")
      end

      it "includes list of presented changed person attributes" do
        changes_presenter.each_pair do |_field, change|
          expect(mail.govuk_notify_personalisation[:changes]).to have_text(change)
        end
      end

      it "includes profile photo changes" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Changed your profile photo")
      end

      it "includes extra info changes" do
        expect(mail.govuk_notify_personalisation[:changes]).to have_text("Changed your extra information")
      end
    end

    context "when updating deleted person" do
      let(:person) { nil }
      let(:changes_presenter) { nil }
      let(:serialized_changes) do
        { 'data': { 'raw': { 'given_name': %w[Smith Jones] } } }.to_json
      end

      it "does not error" do
        expect { mail }.not_to raise_error
      end
    end
  end

  describe ".deleted_profile_email" do
    subject(:mail) { described_class.deleted_profile_email(person.email, person.name, instigator&.email).deliver_now }

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "e8375687-c1c9-4eec-a105-b9b8bc64785d"
    end

    it "includes the persons name" do
      expect(mail.govuk_notify_personalisation[:name]).to eq person.name
    end

    it "includes deleted_by" do
      expect(mail.govuk_notify_personalisation[:deleted_by]).to eq "by #{instigator.email}"
    end

    it "includes contact" do
      expect(mail.govuk_notify_personalisation[:contact]).to eq "#{instigator.email} directly"
    end

    context "when instigator is unknown" do
      let(:instigator) { nil }

      it "includes empty deleted_by" do
        expect(mail.govuk_notify_personalisation[:deleted_by]).to eq ""
      end

      it "includes default contact" do
        expect(mail.govuk_notify_personalisation[:contact]).to eq Rails.configuration.support_email
      end
    end
  end
end
