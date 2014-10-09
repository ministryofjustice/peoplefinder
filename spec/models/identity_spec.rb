require 'rails_helper'

RSpec.describe Identity, type: :model do
  subject { build(:identity, password: password) }
  let(:password) { generate(:password) }

  it 'sets a password digest when password is assigned' do
    subject.password = 'Secure123'
    expect(subject.password_digest).to match(/.{32,}/)
  end

  it 'accepts a correct password' do
    subject.password = 'Secure123'
    expect(subject).to be_valid_password('Secure123')
  end

  it 'rejects an incorrect password' do
    subject.password = 'Secure123'
    expect(subject).not_to be_valid_password('WRONG')
  end

  it 'does not change password_digest for empty password' do
    subject.password = 'Secure123'
    old_digest = subject.password_digest.dup
    subject.password = ''
    expect(subject.password_digest).to eql(old_digest)
  end

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'is not valid if the password confirmation does not match' do
    subject.password = 'Secure123'
    subject.password_confirmation = 'Different456'
    expect(subject).not_to be_valid
  end

  it 'is not valid if the password is short' do
    subject.password = 'a'
    subject.password_confirmation = 'a'
    expect(subject).not_to be_valid
  end

  it 'clears password and password confirmation on save' do
    subject.save
    subject.reload
    expect(subject.password).to be_nil
  end

  it 'does not require password on update' do
    subject.save
    subject.reload
    subject.password = ''
    expect(subject).to be_valid
  end

  it 'returns a user when authenticated correctly' do
    subject.save!
    expect(
      described_class.authenticate(subject.username, password)
    ).to eql(subject.user)
  end

  it 'returns nil when authenticated incorrectly' do
    subject.save!
    expect(
      described_class.authenticate(subject.username, 'WRONG')
    ).to be_nil
  end

  describe '.authenticate' do
    let(:user) { create(:user) }
    let(:password) { generate(:password) }
    let(:identity) { create(:identity, user: user, password: password) }

    it 'returns the user when given the correct username and password' do
      expect(described_class.authenticate(identity.username, password)).
        to eql(user)
    end

    it 'returns nil when given an incorrect password' do
      expect(described_class.authenticate(identity.username, 'WRONG')).
        to be_nil
    end

    it 'returns nil when given a nonexistent username' do
      expect(described_class.authenticate('WRONG', password)).
        to be_nil
    end
  end

  describe '#initiate_password_reset!' do
    let(:identity) { create(:identity) }
    let(:token) { 'I am a token' }

    before do
      allow(SecureRandom).to receive(:hex).with(32) { token }
      identity.initiate_password_reset!
    end

    it 'sets expiry to < 3 hours in the future' do
      expect(identity.password_reset_expires_at).to be < 3.hours.from_now
    end

    it 'sets password_reset_token from SecureRandom' do
      expect(identity.password_reset_token).to eq token
    end

    it 'persists the new token/expiry' do
      expect(identity.changed?).to be_falsy
    end
  end

  describe '#can_reset_password?' do
    context 'expired token' do
      subject { create(:identity, password_reset_expires_at: 2.days.ago) }
      it 'returns false' do
        expect(subject.can_reset_password?).to be_falsy
      end
    end

    context 'unexpired token' do
      subject { create(:identity, password_reset_expires_at: 2.days.from_now) }
      it 'returns true' do
        expect(subject.can_reset_password?).to be_truthy
      end
    end
  end
end
