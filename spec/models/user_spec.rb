require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:email) { generate(:email) }
  let(:password) { generate(:password)}

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
    auth_hash['info']['email'] = 'rogue.user@not-allowed'
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
      user = User.for_email(email)
      expect(user.password_digest).to_not be_blank
    end

    it 'returns a corresponding user for given email' do
      user = create(:user, email: email)
      located_user = User.for_email(user.email)
      expect(located_user).to eql(user)
    end

    it "returns a corresponding user for a given email and doesn't change the password" do
      user = create(:user, email: email, password: password)
      located_user = User.for_email(user.email)
      expect(located_user).to eql(user)
      expect(user.authenticate(password)).to eql(user)
    end

  end



  describe ".set_password_reset_token!" do

    it 'sets a unique password reset token' do
      user = create(:user)
      expect(user.password_reset_token).to be_blank
      user.set_password_reset_token!
      expect(user.password_reset_token).to_not be_blank
    end

  end


  describe ".start_password_reset_flow!" do

    it 'sets a new password reset token and emails the user' do
      user = create(:user)
      expect(user).to receive(:set_password_reset_token!)
      expect(UserMailer).to receive(:password_reset_notification).and_return(double('Mailer', deliver: true))
      user.start_password_reset_flow!
    end

  end

  describe ".update_password!" do
    let(:subject) { create(:user)}

    it 'updates a password given a password and its matching confirmation' do
      expect(subject.update_password!(password, password)).to eql(true)
    end

    it "returns an error if the password and confirmation don't match" do
      expect{subject.update_password!('12345678', 'wibble123')}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'resets the password_reset_token on successful update' do
      subject.set_password_reset_token!
      expect{ subject.update_password!(password, password) }.to change{ subject.password_reset_token }
      subject.set_password_reset_token!
    end


  end

  describe "#from_token" do
    let(:subject) {create(:user)}

    it 'returns a user based on a password_reset_token' do
      subject.set_password_reset_token!
      expect(User.from_token(subject.token)).to eql(subject)
    end

    it 'returns nil if an invalid token is provided' do
      expect(User.from_token(SecureRandom.hex)).to be_nil
    end

    it 'returns nil if an empty token is provided' do
      expect(User.from_token('')).to be_nil
    end

  end


  describe '.invite!' do
    let(:subject) {create(:user)}

    it 'sends an email to the user to complete registration' do
      expect(subject).to receive(:set_password_reset_token!)
      expect(UserMailer).to receive(:registration_notification).and_return(double('Mailer', deliver: true ))
      subject.invite!
    end
  end


end
