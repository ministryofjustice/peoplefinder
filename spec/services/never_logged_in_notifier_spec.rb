require 'rails_helper'

RSpec.describe NeverLoggedInNotifier, type: :service do
  subject { described_class }

  let(:person) { double(Person) }
  let(:mailer) { double(ReminderMailer) }

  before do
    allow(Person).to receive(:never_logged_in).and_return [person]
    allow(person).to receive(:reminder_email_sent?).with(within_days: 30).and_return reminder_email_sent
  end

  describe 'send_reminders' do
    context 'when never-logged-in person has' do

      context 'no reminder email sent within last 30 days' do
        let(:reminder_email_sent) { false }

        it 'sends email to person' do
          mail = double()
          expect(ReminderMailer).to receive(:never_logged_in).with(person).and_return mail
          expect(mail).to receive(:deliver_later)
          subject.send_reminders
        end
      end

      context 'reminder email sent within last 30 days' do
        let(:reminder_email_sent) { true }

        it 'does not send email to person' do
          expect(ReminderMailer).not_to receive(:never_logged_in)
          subject.send_reminders
        end
      end
    end
  end
end
