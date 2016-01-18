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
      expect(subject.obtain_token).to eq new_token
    end
  end

  describe '#obtain_token' do
    context 'when active token exists for given user_email' do
      let!(:token) { double(active?: true, value: 'xyz') }
      let!(:new_token) { double(save: true, valid?: true) }
      before do
        allow(Token).to receive(:find_unspent_by_user_email).and_return token
      end

      it 'returns new token with same value and changes value on original token' do
        expect(Token).to receive(:new).with(user_email: email, value: 'xyz').and_return new_token
        allow(SecureRandom).to receive(:uuid).and_return 'abc'
        expect(token).to receive(:update_attribute).with(:value, 'abc')
        expect(subject.obtain_token).to eq new_token
      end
    end

    context 'when inactive token exists for given user_email' do
      let!(:token) { double(active?: false) }
      before do
        allow(Token).to receive(:find_unspent_by_user_email).and_return token
      end

      it 'does not return existing token' do
        expect(subject.obtain_token).not_to eq token
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
          expect(subject.obtain_token).to eq nil
        end

        it 'sets user_email_error' do
          subject.obtain_token
          expect(subject.user_email_error).to eq error_message
        end
      end
    end
  end

  describe '#call with view' do
    let(:token) { double }
    let(:view) { double }

    context 'when no token obtained' do
      before { allow(subject).to receive(:obtain_token).and_return nil }

      context 'and report_user_email_error? true' do
        it 'calls render_new_view with error' do
          allow(subject).to receive(:report_user_email_error?).and_return true
          allow(subject).to receive(:user_email_error).and_return 'error'

          expect(view).to receive(:render_new_view).with(user_email_error: 'error')
          subject.call(view)
        end
      end

      context 'and report_user_email_error? false' do
        it 'calls render_create_view with nil token' do
          allow(subject).to receive(:report_user_email_error?).and_return false

          expect(view).to receive(:render_create_view).with(token: nil)
          subject.call(view)
        end
      end
    end

    context 'when token obtained' do
      let(:mailer) { double }

      before do
        allow(subject).to receive(:obtain_token).and_return token
        allow(TokenMailer).to receive(:new_token_email).and_return mailer
        allow(mailer).to receive(:deliver_later)
        allow(view).to receive(:render_create_view)
      end

      it 'calls render_create_view with token' do
        expect(view).to receive(:render_create_view).with(token: token)
        subject.call(view)
      end

      it 'sends token email' do
        expect(TokenMailer).to receive(:new_token_email).with(token).and_return mailer
        expect(mailer).to receive(:deliver_later)
        subject.call(view)
      end

    end
  end
end
