require 'rails_helper'

RSpec.describe Token, type: :model do

  it 'generates a token' do
    token = described_class.new
    expect(token.value).to match(/\A[A-Za-z0-9\-_]{20,}\z/)
  end

  it 'preserves the same token after persisting' do
    token = described_class.new
    value = token.value
    token.save!
    token.reload
    expect(token.value).to eql(value)
  end

  it 'returns the user for its object' do
    user = User.new
    token = described_class.new(user: user)
    expect(token.object).to eql(user)
  end

  describe 'expired?' do
    let(:token_timeout)   { Rails.application.config.token_timeout }
    let(:expired_token)   { described_class.new(created_at: Time.now - token_timeout - 1.month) }
    let(:unexpired_token) { described_class.new(created_at: Time.now - token_timeout + 1.month) }

    it 'returns true for expired token' do
      expect(expired_token.expired?).to be true
    end

    it 'returns falase for unexpired token' do
      expect(unexpired_token.expired?).to be false
    end
  end
end
