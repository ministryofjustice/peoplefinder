require 'rails_helper'

RSpec.describe PasswordReset do
  let(:fake_email) { 'hello@example.com' }
  let(:password_reset) { PasswordReset.new(email: fake_email) }

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
      let(:password_reset) { PasswordReset.new(email: fake_email) }
      it 'returns false' do
        expect(password_reset.save).to be_falsy
      end
    end

    context 'email exists' do
      let(:password_reset) { PasswordReset.new(email: user.email) }
      it 'returns true' do
        expect(password_reset.save).to be_truthy
      end
    end
  end
end
