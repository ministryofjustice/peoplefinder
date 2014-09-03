require 'rails_helper'

RSpec.describe ReviewPeriod do

  let(:alice) { create(:user, name: 'alice') }
  let(:bob) { create(:user, name: 'bob', manager: alice) }
  let(:charlie) { create(:user, name: 'charlie', manager: bob) }
  let!(:bobs_review)  { create(:review, subject: bob) }
  let!(:charlies_review)  { create(:review, subject: charlie) }

  subject { ReviewPeriod.new }

  describe '.participants' do
    it 'knows about all three users' do
      [alice, bob, charlie].each do |user|
        expect(subject.participants).to include(user)
      end
    end

    it 'has exactly three elements' do
      expect(subject.participants.length).to eql(3)
    end
  end

  context 'When the REVIEW_PERIOD is CLOSED' do
    before { ENV['REVIEW_PERIOD'] = 'CLOSED' }
    after { ENV['REVIEW_PERIOD'] = nil }

    it 'sends closure notifications to three people' do
      expect {
        subject.send_closure_notifications
      }.to change { ActionMailer::Base.deliveries.count }.by(3)
    end
  end

  context 'When the REVIEW_PERIOD is *not* CLOSED' do

    it 'does not send closure notifications' do
      expect {
        subject.send_closure_notifications
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end
end
