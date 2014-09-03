require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:review) { build(:review) }

  it 'belongs_to a subject' do
    expect(review).to belong_to(:subject)
  end

  it 'has_many tokens' do
    expect(review).to have_many(:tokens)
  end

  describe 'validations' do
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

    it 'restricts status to the whitelist' do
      review.status = 'garbage'
      expect(review).not_to be_valid
    end
  end

  describe 'status' do
    it 'should be "no response" initially' do
      expect(review.status).to eql(:no_response)
    end
  end
end
