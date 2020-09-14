require 'rails_helper'
require_relative 'shared_examples_for_notifiers'

RSpec.describe TeamDescriptionNotifier, type: :service do
  include PermittedDomainHelper

  subject { described_class }

  let(:person) { create(:person) }
  let(:group)  do
    team = create(:group)
    team.people << person
    person.reload
    person.memberships.first.update(leader: true)
    team
  end

  let(:mailer) { double(ReminderMailer) }
  let(:mailer_params) { [person, group] }

  before do
    group.update(description_reminder_email_at: description_reminder_email_at)
  end

  describe 'send_reminders' do
    context 'when never-logged-in person created more than 30 days ago has' do

      context 'no reminder email sent' do
        let(:description_reminder_email_at) { nil }
        include_examples 'sends reminder email', :team_description_missing
      end

      context 'reminder email sent over 30 days ago' do
        let(:description_reminder_email_at) { 31.days.ago }
        include_examples 'sends reminder email', :team_description_missing
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
