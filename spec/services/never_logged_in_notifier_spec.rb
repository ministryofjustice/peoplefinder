require 'rails_helper'

RSpec.describe NeverLoggedInNotifier, type: :service do
  include PermittedDomainHelper

  subject { described_class }

  let(:person) { create(:person) }
  let(:mailer) { double(ReminderMailer) }

  before do
    person.update(last_reminder_email_at: last_reminder_email_at)
  end

  shared_examples 'sends email' do
    context 'when config.send_reminder_emails true' do
      it 'sends email to person' do
        allow(Rails.configuration).to receive(:send_reminder_emails).and_return true
        mail = double
        expect(ReminderMailer).to receive(:never_logged_in).with(person).and_return mail
        expect(mail).to receive(:deliver_later)
        subject.send_reminders
      end
    end
    context 'when config.send_reminder_emails false' do
      it 'does not send email to person' do
        allow(Rails.configuration).to receive(:send_reminder_emails).and_return false
        expect(ReminderMailer).not_to receive(:never_logged_in)
        subject.send_reminders
      end
    end
  end

  describe 'send_reminders' do
    context 'when never-logged-in person has' do

      context 'no reminder email sent' do
        let(:last_reminder_email_at) { nil }
        include_examples 'sends email'
      end

      context 'reminder email sent over 30 days ago' do
        let(:last_reminder_email_at) { 31.days.ago }
        include_examples 'sends email'
      end

      context 'reminder email sent within last 30 days' do
        let(:last_reminder_email_at) { 30.days.ago }

        it 'does not send email to person' do
          expect(ReminderMailer).not_to receive(:never_logged_in)
          subject.send_reminders
        end
      end
    end
  end
end
