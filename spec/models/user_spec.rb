require 'rails_helper'

RSpec.describe User, type: :model do
  def build_valid_auth_hash
    {
      'info' => {
        'email' => 'example.user@digital.justice.gov.uk',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'name' => 'John Doe'
      }
    }
  end

  it 'returns a user from a valid auth_hash' do
    auth_hash = build_valid_auth_hash
    user = described_class.from_auth_hash(auth_hash)
    expect(user).not_to be_nil
    expect(user.email).to eql('example.user@digital.justice.gov.uk')
    expect(user.name).to eql('John Doe')
  end

  it 'returns nil from an auth_hash with the wrong domain' do
    auth_hash = build_valid_auth_hash
    auth_hash['info']['email'] = 'rogue.user@example.com'
    user = described_class.from_auth_hash(auth_hash)
    expect(user).to be_nil
  end

  context 'to_s' do
    it 'uses name if available' do
      user = described_class.new('user@example.com', 'John Doe')
      expect(user.to_s).to eql('John Doe')
    end

    it 'uses email if name is unavailable' do
      user = described_class.new('user@example.com')
      expect(user.to_s).to eql('user@example.com')
    end
  end
end
