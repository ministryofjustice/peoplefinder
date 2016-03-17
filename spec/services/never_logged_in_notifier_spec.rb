require 'rails_helper'
require_relative 'shared_examples_for_notifiers'

RSpec.describe NeverLoggedInNotifier, type: :service do
  include PermittedDomainHelper

  subject { described_class }

  let(:person) { create(:person) }
  let(:mailer) { double(ReminderMailer) }
  let(:mailer_params) { [person] }

  before do
    person.update(last_reminder_email_at: last_reminder_email_at)
    person.update(created_at: Time.now - 31.days)
  end

  describe 'send_reminders' do
    context 'when never-logged-in person created more than 30 days ago has' do

      context 'no reminder email sent' do
        let(:last_reminder_email_at) { nil }
        include_examples 'sends reminder email', :never_logged_in
      end

      context 'reminder email sent over 30 days ago' do
        let(:last_reminder_email_at) { 31.days.ago }
        include_examples 'sends reminder email', :never_logged_in
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
