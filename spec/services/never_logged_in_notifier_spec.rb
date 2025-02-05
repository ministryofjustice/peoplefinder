require "rails_helper"
require_relative "shared_examples_for_notifiers"

RSpec.describe NeverLoggedInNotifier, type: :service do
  include PermittedDomainHelper

  let(:person) { create(:person) }
  let(:mailer) { instance_double(ReminderMailer) }
  let(:mailer_params) { [person] }
  let(:more_than_30_days_ago) { Time.zone.now - 31.days }
  let(:less_than_30_days_ago) { Time.zone.now - 30.days }

  describe ".send_reminders" do
    before do
      person.update!(last_reminder_email_at: nil)
      person.update!(created_at: more_than_30_days_ago)
      allow(described_class).to receive(:send_never_logged_in_reminder?)
        .with(person, 30.days).and_return can_send
    end

    context "when send_never_logged_in_reminder? is true" do
      let(:person) { Person.create!(skip_must_have_team: true, given_name: "Peter", surname: "Piper", email: "peter.piper@digital.justice.gov.uk") }
      let(:can_send) { true }

      include_examples "sends reminder email", :never_logged_in

      it "updates the reminder sent date" do
        allow(Rails.configuration).to receive(:send_reminder_emails).and_return true

        expect {
          described_class.send_reminders
        }.to(change { person.reload.last_reminder_email_at })
      end
    end

    context "when send_never_logged_in_reminder? is false" do
      let(:can_send) { false }

      it "does not send email to person" do
        expect(ReminderMailer).not_to receive(:never_logged_in)
        described_class.send_reminders
      end
    end
  end

  describe ".people_to_remind" do
    let(:within) { 30.days }
    # rubocop:disable RSpec/LetSetup
    let!(:person_logged_in_never_reminded_created_long_ago) { create(:person, login_count: 1, created_at: 60.days.ago) }
    let!(:person_never_logged_in_reminded_recently) { create(:person, login_count: 0) }
    let!(:person_never_logged_in_created_recently) { create(:person, login_count: 0, created_at: 1.day.ago) }
    let!(:person_never_logged_in_reminded_recently_created_long_ago) { create(:person, login_count: 0, created_at: 60.days.ago, last_reminder_email_at: 1.day.ago) }
    let!(:person_never_logged_in_reminded_long_ago_created_long_ago) { create(:person, login_count: 0, created_at: 60.days.ago, last_reminder_email_at: 50.days.ago) }
    let!(:person_never_logged_in_never_reminded_created_long_ago) { create(:person, login_count: 0, created_at: 60.days.ago) }
    # rubocop:enable RSpec/LetSetup

    it "returns expected people" do
      expect(described_class.people_to_remind(within)).to contain_exactly(
        person_never_logged_in_reminded_long_ago_created_long_ago,
        person_never_logged_in_never_reminded_created_long_ago,
      )
    end
  end

  describe "send_never_logged_in_reminder?" do
    context "when person created within last 30 days" do
      before { person.update(created_at: less_than_30_days_ago) }

      it "returns false" do
        expect(described_class.send_never_logged_in_reminder?(person, 30.days)).to be false
      end
    end

    context "when person created more than 30 days ago" do
      before { person.update(created_at: more_than_30_days_ago) }

      it "returns true when never logged in and no reminder sent within last 30 days" do
        allow(person).to receive(:reminder_email_sent?).and_return false
        expect(described_class.send_never_logged_in_reminder?(person, 30.days)).to be true
      end

      it "returns false when logged in before" do
        allow(person).to receive(:reminder_email_sent?).and_return false
        person.login_count = 1
        expect(described_class.send_never_logged_in_reminder?(person, 30.days)).to be false
      end

      it "returns false when reminder sent within last 30 days" do
        allow(person).to receive(:reminder_email_sent?).and_return true
        expect(described_class.send_never_logged_in_reminder?(person, 30.days)).to be false
      end
    end
  end
end
