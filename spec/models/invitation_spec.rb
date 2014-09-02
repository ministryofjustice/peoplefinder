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
    it 'only allows changes to valid states' do
      expect(subject.change_state(:lets_go_for_a_swim.to_s)).to be_falsey
      expect(subject.change_state(:rejected.to_s)).to be_truthy
    end

    it 'can take an optional rejection reason' do
      subject.change_state(:rejected.to_s, "I don't know you")
      expect(subject.rejection_reason).to eql("I don't know you")
    end

    it 'sends a rejection email to invite creator if the invite has been rejected' do
      invitation = create(:invitation)
      expect { invitation.change_state(:rejected.to_s) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '.rejected?' do
    it 'returns true if the current status is :rejected, else false' do
      invitation = create(:invitation)
      expect(invitation.status).to eql(:no_response)
      expect(invitation.rejected?).to be_falsey

      invitation.change_state(:rejected.to_s)
      expect(invitation.reload.rejected?).to be_truthy
    end
  end
end
