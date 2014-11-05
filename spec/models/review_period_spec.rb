require 'rails_helper'

RSpec.describe ReviewPeriod do

  let(:alice) { create(:user, name: 'alice') }
  let(:bob) { create(:user, name: 'bob', manager: alice) }
  let(:charlie) { create(:user, name: 'charlie', manager: bob) }

  subject { described_class }

  context 'With no review period set' do
    before do
      described_class.delete_all
    end

    it 'is closed when there is no DB record' do
      expect(described_class).to be_closed
      expect(described_class).not_to be_open
    end

    it 'is closed when there is a DB record with closes_at in the past' do
      described_class.create!(closes_at: Time.now - 1)
      expect(described_class).to be_closed
      expect(described_class).not_to be_open
    end

    it 'is open when there is a DB record with closes_at in the future' do
      described_class.create!(closes_at: Time.now + 60)
      expect(described_class).to be_open
      expect(described_class).not_to be_closed
    end

    it 'stores closes_at' do
      time = Time.now + 3600
      described_class.closes_at = time
      expect(described_class.first.closes_at.to_i).to eql(time.to_i)
    end
  end

  context 'When the review_period is closed' do
    before do
      close_review_period
    end

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

  context 'When the review_period is open' do
    before do
      open_review_period
    end

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

  context 'Closing time' do
    it 'reports the closing time when set' do
      t = Time.at(1415184252)
      described_class.closes_at = t
      expect(described_class.closes_at).to eql(t)
    end

    it 'reports nil for the closing time when not set' do
      expect(described_class.closes_at).to be_nil
    end

    it 'reports the time left when there is time left' do
      described_class.closes_at = Time.at(1415184252)
      expect(described_class.seconds_left(Time.at(1415180000))).to eql(4252)
    end

    it 'reports the time left as zero when not set' do
      expect(described_class.seconds_left).to eql(0)
    end

    it 'reports the time left as zero when closed' do
      described_class.closes_at = Time.at(1415170000)
      expect(described_class.seconds_left(Time.at(1415180000))).to eql(0)
    end
  end
end
