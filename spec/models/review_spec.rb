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

    it 'requires an @ in the author_email' do
      review.author_email = 'bad'
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

    it 'requires the subject to be a participant' do
      review.subject.participant = false
      expect(review).not_to be_valid
    end

    it 'restricts status to the whitelist' do
      review.status = 'garbage'
      expect(review).not_to be_valid
    end

    it 'is valid if fields are empty and status is not submitted' do
      review.rating_2 = nil
      review.status = :started
      expect(review).to be_valid
    end

    it 'is invalid if fields are empty and status is submitted' do
      review.rating_2 = nil
      review.status = :submitted
      expect(review).not_to be_valid
    end
  end

  describe 'status' do
    it 'is "no response" initially' do
      expect(review.status).to eql(:no_response)
    end
  end

  describe 'invitation message' do
    it 'has a default value' do
      expect(review.invitation_message).to match(/offer 360 feedback/)
    end
  end

  it 'is remindable if the status is no_response, accepted, or started' do
    %i[ no_response accepted started ].each do |status|
      review.status = status
      expect(review).to be_remindable
    end
  end

  it 'is not remindable if the status is declined or submitted' do
    %i[ declined submitted ].each do |status|
      review.status = status
      expect(review).not_to be_remindable
    end
  end

  it 'is complete if the status is submitted' do
    review.status = :submitted
    expect(review).to be_complete
  end

  it 'is not complete if the status is not submitted' do
    %i[ no_response declined accepted started ].each do |status|
      review.status = status
      expect(review).not_to be_complete
    end
  end

  it 'delegates author_name to the author if possible' do
    author = create(:user, name: 'Robert Roberts')
    review = create(:review, author: author, author_name: 'bob')
    expect(review.author_name).to eql('Robert Roberts')
  end

  it 'uses its own author_name if delegation is not possible' do
    review = build(:review, author_name: 'bob')
    expect(review.author_name).to eql('bob')
  end
end
