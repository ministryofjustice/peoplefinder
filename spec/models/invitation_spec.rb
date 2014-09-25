require 'rails_helper'

RSpec.describe Invitation do
  describe '.communicate_change' do
    it 'sends appropriate messaging should an invitation be declined' do
      invitation = create(:invitation)
      invitation.update!(status: :declined, reason_declined: 'because')
    end
  end

  describe '.change_state' do
    let(:subject) { create(:invitation) }
    let(:reason) { "I don't know you" }

    it 'only allows changes to valid states' do
      expect(subject.change_state(:lets_go_for_a_swim.to_s, reason)).to be_falsey
      expect(subject.change_state(:declined.to_s, reason)).to be_truthy
    end

    it 'sets the reason for declining' do
      subject.change_state(:declined.to_s, reason)
      expect(subject.reason_declined).to eql("I don't know you")
    end

    it 'mandates a reason if the invitation is declined' do
      expect(subject.change_state(:declined.to_s)).to be_falsey
      expect(subject.errors[:reason_declined]).to include('If declining, please include a reason')
    end

    it "doesn't mandate a reason if not declining" do
      expect(subject.change_state(:accepted.to_s)).to be_truthy
    end

    it 'sends a declined email to invite creator if the invite has been declined' do
      invitation = create(:invitation)
      expect { invitation.change_state(:declined.to_s, 'Too busy listening to music') }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '.declined?' do
    it 'returns true if the current status is :declined, else false' do
      invitation = create(:invitation)
      expect(invitation.status).to eql(:no_response)
      expect(invitation.declined?).to be_falsey

      invitation.change_state(:declined.to_s, 'I only worked with you briefly')
      expect(invitation.reload.declined?).to be_truthy
    end
  end
end
