require 'rails_helper'

RSpec.describe Peoplefinder::Token, type: :model do
  it 'generates a token' do
    token = create(:token)
    expect(token.value).to match(/\A[a-z0-9\-]{36}\z/)
  end

  it 'preserves the same token after persisting' do
    token = create(:token)
    value = token.value
    token.save!
    token.reload
    expect(token.value).to eql(value)
  end

  it 'will be valid with valid email address' do
    token = build(:token)
    expect(token).to be_valid
  end

  it 'will be invalid with invalid email address' do
    token = build(:token, user_email: 'bob')
    expect(token).not_to be_valid
  end

  it 'will be invalid with email address from wrong domain' do
    token = build(:token, user_email: 'bob@example.com')
    expect(token).not_to be_valid
  end

  describe '#for_person' do
    let(:person) { create(:person, email: 'text.user@digital.justice.gov.uk') }
    let(:token) { described_class.for_person(person) }

    it 'creates a token for that person\'s email' do
      expect(token.user_email).to eql(person.email)
    end
  end
end
