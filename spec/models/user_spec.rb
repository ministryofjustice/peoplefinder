require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:email) { 'example.user@digital.justice.gov.uk' }

  def build_valid_auth_hash
    {
      'info' => {
        'email' => email,
        'first_name' => 'John',
        'last_name' => 'Doe',
        'name' => 'John Doe',
      }
    }
  end

  it "should return a user from a valid auth_hash" do
    auth_hash = build_valid_auth_hash
    user = User.from_auth_hash(auth_hash)
    expect(user).not_to be_nil
    expect(user.email).to eql(email)
    expect(user.name).to eql('John Doe')
  end

  it "should return nil from an auth_hash with the wrong domain" do
    auth_hash = build_valid_auth_hash
    auth_hash['info']['email'] = 'rogue.user@example.com'
    user = User.from_auth_hash(auth_hash)
    expect(user).to be_nil
  end

  it "should create a new record if none exists" do
    auth_hash = build_valid_auth_hash
    user = User.from_auth_hash(auth_hash)
    expect(User.where(email: email).first).to eql(user)
  end

  it "should return an existing record" do
    existing = create(:user, email: email)
    auth_hash = build_valid_auth_hash
    user = User.from_auth_hash(auth_hash)
    expect(user.id).to eql(existing.id)
  end

  it "should update the name of the existing record" do
    existing = create(:user, email: email, name: 'OLD NAME')
    auth_hash = build_valid_auth_hash
    user = User.from_auth_hash(auth_hash)
    user.reload
    expect(user.name).to eql('John Doe')
  end

  context "to_s" do
    it "should use name if available" do
      user = User.new
      user.name = 'John Doe'
      expect(user.to_s).to eql('John Doe')
    end

    it "should use email if name is unavailable" do
      user = User.new
      user.email = 'user@example.com'
      expect(user.to_s).to eql('user@example.com')
    end
  end
end
