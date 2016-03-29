require 'rails_helper'
require_relative 'shared_examples_for_notifiers'

RSpec.describe PersonUpdateNotifier, type: :service do
  include PermittedDomainHelper

  subject { described_class }

  let(:person) { create(:person, login_count: 1) }
  let(:mailer) { double(ReminderMailer) }
  let(:mailer_params) { [person] }

  describe 'send_reminders' do
    before do
      allow(described_class).to receive(:send_update_reminder?).
        with(person).and_return can_send
    end

    context 'when send_update_reminder?(person) is true' do
      let(:can_send) { true }

      include_examples 'sends reminder email', :person_profile_update
    end

    context 'when send_update_reminder?(person) is false' do
      let(:can_send) { false }

      it 'does not send email to person' do
        expect(ReminderMailer).not_to receive(:person_profile_update)
        subject.send_reminders
      end
    end
  end

  describe 'send_update_reminder?' do
    context 'when person has never logged in' do
      it 'returns false' do
        allow(person).to receive(:login_count).and_return 0
        expect(described_class.send_update_reminder?(person)).to be false
      end
    end

    context 'when person has logged in before' do

      before do
        allow(person).to receive(:login_count).and_return 1
      end

      it 'returns false when last login more than 6 months ago' do
        person.update(updated_at: Time.now - (6.months + 1.day))
        expect(described_class.send_update_reminder?(person)).to be false
      end

      it 'returns false when last login within last 6 months and last reminder sent within 6 months' do
        person.update(created_at: Time.now - 6.months)
        person.update(last_reminder_email_at: Time.now - 6.months)
        expect(described_class.send_update_reminder?(person)).to be false
      end

      it 'returns true when last login within last 6 months and last reminder sent more than 6 months ago' do
        person.update(created_at: Time.now - 6.months)
        person.update(last_reminder_email_at: Time.now - (6.months + 1.day))
        expect(described_class.send_update_reminder?(person)).to be true
      end

      it 'returns true when last login within last 6 months and no last reminder sent' do
        person.update(created_at: Time.now - 6.months)
        person.update(last_reminder_email_at: nil)
        expect(described_class.send_update_reminder?(person)).to be true
      end
    end
  end

end
