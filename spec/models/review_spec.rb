require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:review) { Review.new }

  it 'belongs_to a subject' do
    expect(review).to belong_to(:subject)
  end

  describe 'validations' do
    let(:review) { build(:review) }

    it 'is valid' do
      expect(review).to be_valid
    end

    it 'requires an author_email' do
      review.author_email = nil
      expect(review).not_to be_valid
    end

    it 'requires an author_name' do
      review.author_name = nil
      expect(review).not_to be_valid
    end

    it 'requires a subject' do
      review.subject = nil
      expect(review).not_to be_valid
    end
  end
end
