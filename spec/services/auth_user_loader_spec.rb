require 'rails_helper'

describe AuthUserLoader, auth_user_loader: true do
  context '.find_auth_email' do
    subject { described_class.find_auth_email(email) }

    context 'when an auth user with is not found' do
      let(:email) { 'nobody@example.com' }

      it { expect(subject).to be_nil }
    end

    context 'when an auth user is found' do
      let(:email) { 'somebody@example.com' }

      it { expect(subject).to eq('auth_user@example.com') }
    end
  end
end
