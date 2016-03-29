require 'rails_helper'
require_relative 'shared_examples_for_notifiers'

RSpec.describe NeverLoggedInNotifier, type: :service do
  include PermittedDomainHelper

  subject { described_class }

  let(:person) { create(:person) }
  let(:mailer) { double(ReminderMailer) }
  let(:mailer_params) { [person] }

  describe 'send_reminders' do
    before do
      allow(described_class).to receive(:send_never_logged_in_reminder?).
        with(person).and_return can_send
    end

    context 'when send_never_logged_in_reminder? is true' do
      let(:can_send) { true }

      include_examples 'sends reminder email', :never_logged_in
    end

    context 'when send_never_logged_in_reminder? is false' do
      let(:can_send) { false }

      it 'does not send email to person' do
        expect(ReminderMailer).not_to receive(:never_logged_in)
        subject.send_reminders
      end
    end
  end

  describe 'send_never_logged_in_reminder?' do
    context 'when person created within last 30 days' do
      before { person.update(created_at: Time.now - 30.days) }
      it 'returns false' do
        expect(described_class.send_never_logged_in_reminder?(person)).to be false
      end
    end

    context 'when person created more than 30 days ago' do
      before { person.update(created_at: Time.now - 31.days) }

      it 'returns true when never logged in and no reminder sent within last 30 days' do
        allow(person).to receive(:reminder_email_sent?).and_return false
        expect(described_class.send_never_logged_in_reminder?(person)).to be true
      end

      it 'returns false when logged in before' do
        allow(person).to receive(:reminder_email_sent?).and_return false
        person.login_count = 1
        expect(described_class.send_never_logged_in_reminder?(person)).to be false
      end

      it 'returns false when reminder sent within last 30 days' do
        allow(person).to receive(:reminder_email_sent?).and_return true
        expect(described_class.send_never_logged_in_reminder?(person)).to be false
      end
    end
  end

end
