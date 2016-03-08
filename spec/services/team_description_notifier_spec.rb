require 'rails_helper'

RSpec.describe TeamDescriptionNotifier, type: :service do
  include PermittedDomainHelper

  subject { described_class }

  let(:person) { create(:person) }
  let(:group)  do
    team = create(:group)
    team.people << person
    person.memberships.first.update(leader: true)
    team
  end

  let(:mailer) { double(ReminderMailer) }

  before do
    group.update(description_reminder_email_at: description_reminder_email_at)
  end

  shared_examples 'sends email' do
    context 'when config.send_reminder_emails true' do
      it 'sends email to team leaders of group' do
        allow(Rails.configuration).to receive(:send_reminder_emails).and_return true
        mail = double
        expect(ReminderMailer).to receive(:team_description_missing).with(person, group).and_return mail
        expect(mail).to receive(:deliver_later)
        subject.send_reminders
      end
    end
    context 'when config.send_reminder_emails false' do
      it 'does not send email' do
        allow(Rails.configuration).to receive(:send_reminder_emails).and_return false
        expect(ReminderMailer).not_to receive(:team_description_missing)
        subject.send_reminders
      end
    end
  end

  describe 'send_reminders' do
    context 'when never-logged-in person created more than 30 days ago has' do

      context 'no reminder email sent' do
        let(:description_reminder_email_at) { nil }
        include_examples 'sends email'
      end

      context 'reminder email sent over 30 days ago' do
        let(:description_reminder_email_at) { 31.days.ago }
        include_examples 'sends email'
      end

      context 'reminder email sent within last 30 days' do
        let(:description_reminder_email_at) { 30.days.ago }

        it 'does not send email' do
          allow(Rails.configuration).to receive(:send_reminder_emails).and_return true
          expect(ReminderMailer).not_to receive(:team_description_missing)
          subject.send_reminders
        end
      end
    end
  end
end
