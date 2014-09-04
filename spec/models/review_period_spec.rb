require 'rails_helper'

RSpec.describe ReviewPeriod do

  let(:alice) { create(:user, name: 'alice') }
  let(:bob) { create(:user, name: 'bob', manager: alice) }
  let(:charlie) { create(:user, name: 'charlie', manager: bob) }

  subject { ReviewPeriod.new }

  context 'When the REVIEW_PERIOD is CLOSED', closed_review_period: true do
    let!(:bobs_review)  { create(:review, subject: bob) }
    let!(:charlies_review)  { create(:review, subject: charlie) }

    it 'does not send introduction emails' do
      expect(Introduction).not_to receive(:new)
      subject.send_introductions
    end

    it 'sends closure notifications to three people' do
      expect {
        subject.send_closure_notifications
      }.to change { ActionMailer::Base.deliveries.count }.by(3)
    end
  end

  context 'When the REVIEW_PERIOD is *not* CLOSED' do

    it 'sends introduction emails to each user' do
      [alice, bob, charlie].each do |user|
        intro = double(Introduction)
        expect(Introduction).to receive(:new).with(user) { intro }
        expect(intro).to receive(:send)
      end
      subject.send_introductions
    end

    it 'does not send closure notifications' do
      expect {
        subject.send_closure_notifications
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end
end
