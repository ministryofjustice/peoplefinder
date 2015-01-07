require 'rails_helper'

RSpec.describe PasswordReset, type: :model do
  let(:fake_email) { 'hello@example.com' }
  let(:password_reset) { described_class.new(email: fake_email) }

  let(:password) { generate(:password) }
  let(:user) { create(:admin_user) }
  let!(:identity) { create(:identity, password: password, user: user) }

  describe '#email' do
    it 'returns the email passed into constructor' do
      expect(password_reset.email).to eq fake_email
    end
  end

  describe '#save' do
    context "email doesn't exist" do
      let(:password_reset) { described_class.new(email: fake_email) }
      it 'returns false' do
        expect(password_reset.save).to be_falsy
      end

      it 'sets relevant error' do
        password_reset.save
        expect(password_reset.errors.full_messages).to include 'No admin user with that email exists'
      end
    end

    context 'email exists' do
      let(:email) { 'hello@example.com' }
      let(:password_reset) { described_class.new(email: email) }
      let(:identity) { double(:identity) }
      let(:user) { double(:user, primary_identity: identity) }

      before do
        allow(User).to receive(:find_admin_by_email).with(email).and_return(user)
        allow(identity).to receive(:initiate_password_reset!).and_return(true)
      end

      it 'returns true' do
        expect(password_reset.save).to be_truthy
      end

      it 'calls #initiate_password_reset! on identity' do
        expect(identity).to receive(:initiate_password_reset!)
        password_reset.save
      end
    end
  end

  describe '#token' do
    let(:email) { 'hello@example.com' }
    let(:token) { "This here is the token" }
    let(:password_reset) { described_class.new(email: email) }
    let(:identity) { double(:identity, password_reset_token: token) }
    let(:user) { double(:user, primary_identity: identity) }

    before do
      allow(User).to receive(:find_admin_by_email).with(email).and_return(user)
    end

    it 'returns the password reset token of the associated identity' do
      expect(password_reset.token).to eq token
    end
  end
end
