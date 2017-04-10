require 'rails_helper'
require_relative '../../app/services/token_sender'

RSpec.describe TokenSender, type: :service do
  include PermittedDomainHelper

  subject { described_class.new(email) }

  let(:email) { 'user.name@digital.justice.gov.uk' }
  let(:view) { double }

  def assigned_token
    subject.instance_variable_get(:@token)
  end

  shared_examples 'generates token' do
    before do
      allow(view).to receive(:render_create_view)
    end

    it 'generates a new token' do
      expect { subject.call(view) }.to change(Token, :count).by 1
    end
  end

  describe '#obtain_token' do
    context 'when active token exists for given user_email' do
      let!(:token) { double(active?: true, value: 'xyz') }
      let!(:new_token) { double(save: true, valid?: true) }
      before do
        allow(Token).to receive(:find_unspent_by_user_email).and_return token
        allow(SecureRandom).to receive(:uuid).and_return 'abc'
      end

      it 'creates new token with same value as original' do
        expect(Token).to receive(:new).with(user_email: email, value: 'xyz').and_return new_token
        allow(token).to receive(:update_attribute).with(:value, 'abc')
        subject.obtain_token
        expect(assigned_token).to eql new_token
      end

      it 'changes value of original token' do
        allow(Token).to receive(:new).with(user_email: email, value: 'xyz').and_return new_token
        expect(token).to receive(:update_attribute).with(:value, 'abc')
        subject.obtain_token
      end

      it 'returns true' do
        allow(Token).to receive(:new).with(user_email: email, value: 'xyz').and_return new_token
        allow(token).to receive(:update_attribute).with(:value, 'abc')
        expect(subject.obtain_token).to eq true
      end
    end

    context 'when inactive token exists for given user_email' do
      let!(:token) { double(active?: false) }
      before do
        allow(Token).to receive(:find_unspent_by_user_email).and_return token
      end

      include_examples 'generates token'

      it 'does not rebuild the existing token' do
        subject.obtain_token
        expect(assigned_token).not_to eql token
      end
    end

    context 'when no token exists for given user_email' do
      include_examples 'generates token'

      context 'and error when saving new token' do
        let(:error_message) { 'Email address is not formatted correctly' }
        before do
          new_token = double(save: false, errors: { user_email: [error_message] })
          allow(Token).to receive(:new).with(user_email: email).and_return new_token
        end

        it 'returns false' do
          expect(subject.obtain_token).to eq false
        end

         it 'assigns token with errors' do
          subject.obtain_token
          expect(assigned_token.errors[:user_email]).to include error_message
        end
      end
    end
  end

  describe '#call with view' do
    context 'when no token obtained' do
      let(:new_token) { double(save: false, valid?: false, errors: { user_email: ['my error'] }) }

      before do
        allow(Token).to receive(:new).with(user_email: email).and_return new_token
      end

      context 'and a specific type of error is raised (email invalid or token limit exceeded)' do
        before do
          allow(subject).to receive(:user_email_error?).and_return true
        end

        it 'calls render_new_view_with_errors with erroneous token' do
          expect(view).to receive(:render_new_view_with_errors).with(token: new_token)
          subject.call(view)
        end
      end

      context 'and an unexpected error is raised' do
        before do
          allow(subject).to receive(:user_email_error?).and_return false
        end
        it 'calls render_create_view with nil token' do
          expect(view).to receive(:render_create_view).with(token: nil)
          subject.call(view)
        end
      end
    end

    context 'when token obtained' do
      let(:token) { double(save: true, valid?: true) }
      let(:mailer) { double }

      before do
        allow(Token).to receive(:new).with(user_email: email).and_return token
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
        expect(mailer).to receive(:deliver_later).with(queue: :high_priority)
        subject.call(view)
      end

    end
  end
end
