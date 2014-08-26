require 'rails_helper'

RSpec.describe Token, type: :model do
  it "generates a token" do
    token = described_class.new
    expect(token.value).to match(/\A[a-z0-9\-]{36}\z/)
  end

  it "preserves the same token after persisting" do
    token = described_class.new
    value = token.value
    token.save!
    token.reload
    expect(token.value).to eql(value)
  end
end
