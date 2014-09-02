require 'rails_helper'

RSpec.describe ReviewPeriod, type: :model do

  let(:review_period) { ReviewPeriod.new }

  context 'With a new review period' do
    before do
      review_period.save!
    end

    it 'knows it is the current period' do
      expect(ReviewPeriod.current).to eql(review_period)
    end

    context 'when it is closed' do
      before { review_period.close! }

      it 'adds the end date' do
        expect(review_period.ended_at).to be_present
      end

      it 'resets the current period' do
        expect(ReviewPeriod.current).to be nil
      end

      it 'allows the creation of a new period' do
        expect(ReviewPeriod.create!).to be_valid
      end
    end

    context 'when there is already an open review period' do
      it 'does not allow a new one to be created' do
        expect(
          ReviewPeriod.create.errors[:base]
        ).to include(/already a current review period/)
      end

      it 'does not allow closure notifications' do
        expect(review_period.send_closure_notifications).to be false
      end
    end
  end

  context 'with several particpants' do
    let(:alice) { create(:user, name: 'alice') }
    let(:bob) { create(:user, name: 'bob', manager: alice) }
    let(:charlie) { create(:user, name: 'charlie', manager: bob) }
    let!(:bobs_review)  { create(:review, subject: bob) }
    let!(:charlies_review)  { create(:review, subject: charlie) }
    let(:review_period) { bobs_review.review_period }

    describe '.participants' do
      it 'knows about all three users' do
        [alice, bob, charlie].each do |user|
          expect(review_period.participants).to include(user)
        end
      end

      it 'has exactly three elements' do
        expect(review_period.participants.length).to eql(3)
      end
    end

    context '.send_closure_notifications' do
      before { review_period.close! }

      it 'sends closure notifications to three people' do
        expect {
          review_period.send_closure_notifications
        }.to change { ActionMailer::Base.deliveries.count }.by(3)
      end
    end
  end
end
