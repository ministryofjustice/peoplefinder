require 'rails_helper'

RSpec.describe TabularReviewAggregator, type: :model do
  it 'has a header row listing all reviewer names' do
    review_1 = build(:review, author_name: 'Alice')
    review_2 = build(:review, author_name: 'Bob')
    aggregator = described_class.new([review_1, review_2])
    expect(aggregator.first).to eql([:question, 'Alice', 'Bob'])
  end

  it 'lists each question' do
    aggregator = described_class.new([])
    expected = [
      :rating_1, :rating_2, :rating_3, :rating_4, :leadership_comments,
      :rating_5, :rating_6, :rating_7, :rating_8, :rating_9, :rating_10,
      :rating_11, :how_we_work_comments
    ]
    expect(aggregator.drop(1).map(&:first)).to eql(expected)
  end

  it 'lists the answers for each question and reviewer' do
    review_1 = build(
      :review,
      rating_1: 1, rating_2: 2, rating_3: 3, rating_4: 4,
      leadership_comments: 'hoge',
      rating_5: 5, rating_6: 1, rating_7: 2, rating_8: 3,
      rating_9: 4, rating_10: 5, rating_11: 1,
      how_we_work_comments: 'hoge hoge'
    )
    review_2 = build(
      :review,
      rating_1: 2, rating_2: 2, rating_3: 2, rating_4: 2,
      leadership_comments: 'murrrrr',
      rating_5: 4, rating_6: 4, rating_7: 4, rating_8: 4,
      rating_9: 4, rating_10: 4, rating_11: 4,
      how_we_work_comments: 'brainsssss'
    )
    aggregator = described_class.new([review_1, review_2])
    expected = [
      [1, 2], [2, 2], [3, 2], [4, 2],
      ['hoge', 'murrrrr'],
      [5, 4], [1, 4], [2, 4], [3, 4], [4, 4], [5, 4], [1, 4],
      ['hoge hoge', 'brainsssss']
    ]
    expect(aggregator.drop(1).map { |r| r.drop(1) }).to eql(expected)
  end

  it 'gives nil for a zero score' do
    review_1 = build(:review, rating_1: 0)
    aggregator = described_class.new([review_1])
    expect(aggregator.to_a[1][1]).to be_nil
  end
end
