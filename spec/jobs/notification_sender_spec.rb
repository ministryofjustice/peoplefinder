require 'rails_helper'

describe NotificationSender do
  include PermittedDomainHelper

  describe '#send!' do

    let(:person) { create :person, id: 22 }
    let(:logged_in_user) { create :person, id: 333 }
    let(:mailer) { double UserUpdateMailer }

    it 'calls process group for each group item returned by unsent groups' do
      expect(QueuedNotification).to receive(:unsent_groups).and_return([:group1, :group2, :group3])
      sender = described_class.new
      expect(sender).to receive(:process_group).with(:group1)
      expect(sender).to receive(:process_group).with(:group2)
      expect(sender).to receive(:process_group).with(:group3)
      sender.send!
    end

    context 'processing started by another process after this job started' do
      it 'does not send any mails' do
        Timecop.freeze 1.hour.ago do
          2.times do
            create :queued_notification, session_id: 'abc', person_id: 22, current_user_id: 333
          end
        end
        sender = described_class.new
        QueuedNotification.update_all(processing_started_at: 1.minute.ago)
        sender.send!
        expect(UserUpdateMailer).not_to receive(:updated_profile_email)
        expect(UserUpdateMailer).not_to receive(:new_profile_email)
      end
    end

    context 'first queued notification is new email template' do
      it 'sends a new_profile_email' do
        create_qn(email_template: 'new_profile_email')
        create_qn(email_template: 'updated_profile_email', edit_finalised: true)
        sender = described_class.new
        expect(UserUpdateMailer).to receive(:new_profile_email).with(person, logged_in_user.email).and_return(mailer)
        expect(mailer).to receive(:deliver_later)
        sender.send!
        expect_queued_notifications_to_be_marked_as_sent
      end
    end

    context 'all queued notifications email templates are updated_email_template' do
      it 'sends an updated profile email' do
        create_qn(email_template: 'updated_profile_email')
        create_qn(email_template: 'updated_profile_email', edit_finalised: true)
        sender = described_class.new
        raw_changes = double 'raw changes'
        aggregator = double ProfileChangeAggregator, aggregate_raw_changes: raw_changes
        presenter = double ProfileChangesPresenter, serialize: 'serialized changes'
        expect(ProfileChangeAggregator).to receive(:new).and_return(aggregator)
        expect(ProfileChangesPresenter).to receive(:new).with(raw_changes).and_return(presenter)
        expect(UserUpdateMailer).to receive(:updated_profile_email).with(person, presenter.serialize, logged_in_user.email).and_return(mailer)
        expect(mailer).to receive(:deliver_later)

        sender.send!
      end

    end

    def create_qn(options)
      merged_options = { session_id: 'def', person_id: 22, current_user_id: 333 }.merge(options)
      create :queued_notification, merged_options
    end

    def expect_queued_notifications_to_be_marked_as_sent
      expect(QueuedNotification.all.map(&:sent)).not_to include(false)
    end
  end
end
