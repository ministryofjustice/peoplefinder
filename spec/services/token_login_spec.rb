require 'rails_helper'

RSpec.describe TokenLogin, type: :service do
  include PermittedDomainHelper

  describe '#call' do
    let(:person) { create :person }
    let(:view) { double }
    let(:token) { create :token, user_email: person.email }
    subject(:service) { described_class.new(token.value) }

    it { is_expected.to respond_to :token }

    it 'finds tokens securely' do
      expect_any_instance_of(described_class).to receive(:find_token_securely)
      service
    end

    context 'for active tokens' do
      context 'used in supported browsers' do
        let(:view) { double(supported_browser?: true) }

        it 'logs in and renders view' do
          expect_any_instance_of(described_class).to receive(:login_and_render).with(view)
          service.call view
        end

        it 'spends the token' do
          expect(view).to receive(:person_from_token).with(token).and_return person
          expect(view).to receive(:render_or_redirect_login).with(person).and_return nil
          expect_any_instance_of(Token).to receive(:spend!)
          service.call view
        end
      end

      context 'used in unsupported browsers' do
        let(:view) { double(supported_browser?: false) }
        it 'redirects to unsupported browser page' do
          expect(view).to receive(:redirect_to_unsupported_browser_warning)
          service.call view
        end
      end
    end

    context 'for inactive/spent token' do
      let(:token) { create(:token, spent: true) }
      it 'renders expired token message' do
        expect(view).to receive(:render_new_sessions_path_with_expired_token_message)
        service.call view
      end
    end
  end
end
