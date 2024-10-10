require "rails_helper"
require_relative "shared_examples_for_notifiers"

RSpec.describe PersonUpdateNotifier, type: :service do
  include PermittedDomainHelper

  let(:person) { create(:person, login_count: 1) }
  let(:person_two) { create(:person, surname: "test_last_update", login_count: 1) }
  let(:mailer) { instance_double(ReminderMailer) }
  let(:mailer_params) { [person] }
  let(:more_than_six_months_ago) { Time.zone.now - (6.months + 1.day) }
  let(:less_than_six_months_ago) { Time.zone.now - (6.months - 1.day) }

  describe "send_reminders" do
    before do
      person.update!(last_reminder_email_at: more_than_six_months_ago)
      person.update!(updated_at: more_than_six_months_ago)
      allow(described_class).to receive(:send_update_reminder?)
        .with(person, 6.months).and_return can_send
    end

    context "when send_update_reminder?(person) is true" do
      let(:can_send) { true }

      include_examples "sends reminder email", :person_profile_update
    end

    context "when send_update_reminder?(person) is false" do
      let(:can_send) { false }

      it "does not send email to person" do
        expect(ReminderMailer).not_to receive(:person_profile_update)
        described_class.send_reminders
      end
    end
  end

  describe "send_update_reminder?" do
    context "when person has never logged in" do
      it "returns false" do
        allow(person).to receive(:login_count).and_return 0
        expect(described_class.send_update_reminder?(person, 6.months)).to be false
      end
    end

    context "when person has logged in before" do
      before do
        allow(person).to receive(:login_count).and_return 1
      end

      def check_send_update_reminder(expected)
        expect(described_class.send_update_reminder?(person, 6.months)).to be expected
      end

      context "when no last reminder sent" do
        before { person.update(last_reminder_email_at: nil) }

        it "returns true when last update more than 6 months ago" do
          person.update!(updated_at: more_than_six_months_ago)
          check_send_update_reminder true
        end

        it "returns false when last update less than 6 months ago" do
          person.update!(updated_at: less_than_six_months_ago)
          check_send_update_reminder false
        end
      end

      context "when last reminder sent more than 6 months ago" do
        before { person.update(last_reminder_email_at: more_than_six_months_ago) }

        it "returns true when last update more than 6 months ago" do
          person.update!(updated_at: more_than_six_months_ago)
          check_send_update_reminder true
        end

        it "returns false when last update less than 6 months ago" do
          person.update!(updated_at: less_than_six_months_ago)
          check_send_update_reminder false
        end
      end

      context "when last reminder sent less than 6 months ago" do
        before { person.update(last_reminder_email_at: less_than_six_months_ago) }

        it "returns false when last update more than 6 months ago" do
          person.update!(updated_at: more_than_six_months_ago)
          check_send_update_reminder false
        end

        it "returns false when last update less than 6 months ago" do
          person.update!(updated_at: less_than_six_months_ago)
          check_send_update_reminder false
        end
      end
    end

    describe "sending emails when a person is not on a team" do
      context "when last_reminder_email_at is nil" do
        it "last_reminder_email_at is updated" do
          person_two.skip_must_have_team = true
          person_two.update!(
            last_reminder_email_at: nil,
            memberships: [],
            updated_at: more_than_six_months_ago,
          )
          person_two.skip_must_have_team = false

          expect(described_class.send_update_reminder?(person_two, 6.months)).to be true
          described_class.send(:send_reminder, person_two, 6.months)
          person_two.reload

          expect(person_two.last_reminder_email_at).not_to be_nil
          expect(person_two.last_reminder_email_at.class).to be(ActiveSupport::TimeWithZone)
        end
      end

      context "when last_reminder_email_at is > six months ago" do
        it "last_reminder_email_at is updated" do
          person_two.skip_must_have_team = true
          person_two.update!(
            last_reminder_email_at: more_than_six_months_ago,
            memberships: [],
            updated_at: more_than_six_months_ago,
          )
          person_two.skip_must_have_team = false

          expect(described_class.send_update_reminder?(person_two, 6.months)).to be true
          described_class.send(:send_reminder, person_two, 6.months)
          person_two.reload

          expect(person_two.last_reminder_email_at).not_to be(more_than_six_months_ago)
          expect(person_two.last_reminder_email_at.class).to be(ActiveSupport::TimeWithZone)
        end
      end
    end
  end
end
