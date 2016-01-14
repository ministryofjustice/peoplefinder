require 'rails_helper'
require_relative '../../app/services/token_sender'

RSpec.describe TokenSender, type: :service do
  include PermittedDomainHelper

  let(:email) { 'user.name@digital.justice.gov.uk' }
  subject { described_class.new(email) }

  shared_examples 'generates token' do
    it 'returns new token' do
      new_token = double(save: true)
      allow(Token).to receive(:new).with(user_email: email).and_return new_token
      expect(subject.token).to eq new_token
    end
  end

  describe '#token' do
    context 'when active token exists for given user_email' do
      let!(:token) { double(active?: true) }
      before do
        allow(Token).to receive(:find_by_user_email).and_return token
      end

      it 'returns that token' do
        expect(subject.token).to eq token
      end
    end

    context 'when inactive token exists for given user_email' do
      let!(:token) { double(active?: false) }
      before do
        allow(Token).to receive(:find_by_user_email).and_return token
      end

      it 'does not return existing token' do
        expect(subject.token).not_to eq token
      end

      include_examples 'generates token'
    end

    context 'when no token exists for given user_email' do
      include_examples 'generates token'

      context 'and error when saving new token' do
        let(:error_message) { 'Email address is not formatted correctly' }
        before do
          new_token = double(save: false, errors: { user_email: [error_message] })
          allow(Token).to receive(:new).with(user_email: email).and_return new_token
        end

        it 'returns nil token' do
          expect(subject.token).to eq nil
        end

        it 'sets user_email_error' do
          subject.token
          expect(subject.user_email_error).to eq error_message
        end
      end
    end
  end

end
