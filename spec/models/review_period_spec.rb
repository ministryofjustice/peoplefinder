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
    end
  end
end
