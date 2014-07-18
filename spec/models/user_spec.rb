require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:email) { 'example.user@digital.justice.gov.uk' }
  let(:password) { 'a warm summers day in blighty'}

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


  it "should return nil from an auth_hash with the wrong domain" do
    auth_hash = build_valid_auth_hash
    auth_hash['info']['email'] = 'rogue.user@example.com'
    user = User.from_auth_hash(auth_hash)
    expect(user).to be_nil
  end


  it "should return an existing record" do
    existing = create(:user, email: email)
    auth_hash = build_valid_auth_hash
    user = User.from_auth_hash(auth_hash)
    expect(user.id).to eql(existing.id)
  end


  it "should normalise the email address" do
    user = User.new(email: '"Example User" <Example.User@digital.justice.gov.uk>')
    expect(user.email).to eql('example.user@digital.justice.gov.uk')
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

  describe '#for_email' do

    it 'creates a user with a randomly generated password' do
      user = User.for_email('example.user@digital.justice.gov.uk')
      expect(user.password_digest).to_not be_blank
    end

    it 'returns a corresponding user for given email' do
      user = create(:user, email: email, password: password, password_confirmation: password)
      located_user = User.for_email(user.email)
      expect(located_user).to eql(user)
    end

    it "returns a corresponding user for a given email and doesn't change the password" do
      user = create(:user, email: email, password: password, password_confirmation: password)
      located_user = User.for_email(user.email)
      expect(located_user).to eql(user)
      expect(user.authenticate(password)).to eql(user)
    end

  end


end
