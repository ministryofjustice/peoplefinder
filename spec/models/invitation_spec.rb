require 'rails_helper'

RSpec.describe Invitation do
  describe '.communicate_rejection' do
    it 'sends appropriate messaging should an invitation be rejected' do
      invitation = create(:invitation)
      invitation.update!(status: :rejected)
    end
  end

  describe '.change_state' do
    let(:subject) { create(:invitation) }
    let(:reason) { "I don't know you" }

    it 'only allows changes to valid states' do
      expect(subject.change_state(:lets_go_for_a_swim.to_s, reason)).to be_falsey
      expect(subject.change_state(:rejected.to_s, reason)).to be_truthy
    end

    it 'sets the reason for rejection' do
      subject.change_state(:rejected.to_s, reason)
      expect(subject.rejection_reason).to eql("I don't know you")
    end

    it 'mandates a reason if the invitation is rejected' do
      expect(subject.change_state(:rejected.to_s)).to be_falsey
      expect(subject.errors[:rejection_reason]).to include('If rejecting, please include a reason')
    end

    it "doesn't mandate a reason if not rejecting" do
      expect(subject.change_state(:accepted.to_s)).to be_truthy
    end

    it 'sends a rejection email to invite creator if the invite has been rejected' do
      invitation = create(:invitation)
      expect { invitation.change_state(:rejected.to_s, 'Too busy listening to music') }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '.valid_status?' do
    it 'returns true for a recognized status' do
      invitation = create(:invitation)
      invitation.status = :good_news_everyone
      expect(invitation.valid_status?).to be_falsey

      invitation.status = :accepted
      expect(invitation.valid_status?).to be_truthy
    end
  end

  describe '.valid_reason?' do
    let(:invitation) { create(:invitation) }
    it 'returns true if the reason is empty and the state is not rejected' do
      invitation.rejection_reason = nil
      invitation.status = :accepted
      expect(invitation.valid_reason?).to be_truthy
    end

    it 'returns false if the reason is empty and the state is blank' do
      invitation.rejection_reason = ''
      invitation.status = :rejected
      expect(invitation.valid_reason?).to be_falsey
    end

  end

  describe '.rejected?' do
    it 'returns true if the current status is :rejected, else false' do
      invitation = create(:invitation)
      expect(invitation.status).to eql(:no_response)
      expect(invitation.rejected?).to be_falsey

      invitation.change_state(:rejected.to_s, 'I only worked with you briefly')
      expect(invitation.reload.rejected?).to be_truthy
    end
  end
end
