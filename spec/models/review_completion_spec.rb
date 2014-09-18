require 'rails_helper'

RSpec.describe ReviewCompletion, type: :model do
  it 'calculates the total number of reviews' do
    rc = described_class.new([double(Review), double(Review)])
    expect(rc.total).to eql(2)
  end

  it 'calculates the total number of completed reviews' do
    rc = described_class.new([
      double(Review, complete?: true),
      double(Review, complete?: false),
      double(Review, complete?: true)
    ])
    expect(rc.completed).to eql(2)
  end

  describe 'description' do
    it 'is :none when nothing is complete' do
      rc = described_class.new([
        double(Review, complete?: false),
        double(Review, complete?: false),
        double(Review, complete?: false)
      ])
      expect(rc.description).to eql(:none)
    end

    it 'is :some when some but not all reviews are complete' do
      rc = described_class.new([
        double(Review, complete?: true),
        double(Review, complete?: false),
        double(Review, complete?: false)
      ])
      expect(rc.description).to eql(:some)
    end

    it 'is :all when all are complete' do
      rc = described_class.new([
        double(Review, complete?: true),
        double(Review, complete?: true),
        double(Review, complete?: true)
      ])
      expect(rc.description).to eql(:all)
    end
  end
end
