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

  it "should return a user from a valid auth_hash" do
    auth_hash = build_valid_auth_hash
    user = User.from_auth_hash(auth_hash)
    expect(user).not_to be_nil
    expect(user.email).to eql('example.user@digital.justice.gov.uk')
    expect(user.name).to eql('John Doe')
  end

  it "should return nil from an auth_hash with the wrong domain" do
    auth_hash = build_valid_auth_hash
    auth_hash['info']['email'] = 'rogue.user@example.com'
    user = User.from_auth_hash(auth_hash)
    expect(user).to be_nil
  end

  context "to_s" do
    it "should use name if available" do
      user = User.new('user@example.com', 'John Doe')
      expect(user.to_s).to eql('John Doe')
    end

    it "should use email if name is unavailable" do
      user = User.new('user@example.com')
      expect(user.to_s).to eql('user@example.com')
    end
  end
end
