require 'rails_helper'

RSpec.describe ReviewAggregator, type: :model do
  it 'enumerates over each reviewer and rating for each question' do
    review_1 = build(:review, author_name: 'Alice', rating_1: 4)
    review_2 = build(:review, author_name: 'Bob', rating_1: 2)
    aggregator = described_class.new([review_1, review_2])
    expect(aggregator.results(:rating_1)).to eql([['Alice', 4], ['Bob', 2]])
  end

  it 'skips zero ratings' do
    review_1 = build(:review, author_name: 'Alice', rating_1: 4)
    review_2 = build(:review, author_name: 'Bob', rating_1: 0)
    aggregator = described_class.new([review_1, review_2])
    expect(aggregator.results(:rating_1)).to eql([['Alice', 4]])
  end

  it 'skips empty comments' do
    review_1 = build(:review, author_name: 'Alice', leadership_comments: 'foo')
    review_2 = build(:review, author_name: 'Bob', leadership_comments: ' ')
    aggregator = described_class.new([review_1, review_2])
    expect(aggregator.results(:leadership_comments)).to eql([%w[Alice foo]])
  end
end
