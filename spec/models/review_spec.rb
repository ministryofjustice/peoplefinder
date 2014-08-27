require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:review) { Review.new }

  it 'belongs_to a subject' do
    expect(review).to belong_to(:subject)
  end

  it 'has_many tokens' do
    expect(review).to have_many(:tokens)
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

  describe '.send_feedback_request' do
    let(:review) { create(:review) }
    subject { review.send_feedback_request }

    it 'sends a feedback request email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
