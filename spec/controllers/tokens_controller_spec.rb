require 'rails_helper'

describe TokensController, type: :controller do
  include PermittedDomainHelper

  it_behaves_like 'session_person_creatable'
  it_behaves_like 'user_agent_helpable'

  describe 'GET show' do
    let(:person) { create(:person) }
    let(:token) { create(:token, user_email: person.email) }

    context 'user is logged in' do
      before do
        allow(controller).to receive(:current_user).and_return person
        allow(controller).to receive(:logged_in_regular?).and_return true
      end

      it 'redirects to person profile' do
        get :show, params: { id: token }
        expect(response).to redirect_to person_path(person)
      end

      context 'when desired path is set' do
        before { request.session[:desired_path] = new_group_path }
        it 'redirects to desired path' do
          get :show, params: { id: token }
          expect(response).to redirect_to new_group_path
        end
      end
    end

    context 'user is not logged in' do
      before do
        allow(controller).to receive(:current_user).and_return nil
        allow(controller).to receive(:logged_in_regular?).and_return false
      end

      it 'redirects to person profile' do
        get :show, params: { id: token }
        expect(response).to redirect_to person_path(person, prompt: 'profile')
      end

      context 'when desired path is set' do
        before { request.session[:desired_path] = new_group_path }
        it 'redirects to desired path' do
          get :show, params: { id: token }
          expect(response).to redirect_to new_group_path
        end
      end
    end

    context 'securly verifies that a token is valid and active' do
      describe 'avoiding a method with differning repsonse times for valid and invalid tokens' do
        it 'does not use Token.where(value: param[:id]).first' do
          expect(Token).not_to receive(:where)
          get :show, params: { id: 'some token value' }
        end
      end

      describe 'using a method that takes a constant time regardless of the validity of the token' do
        it 'loops over a block of tokens and finds the first match using Secure.compare' do
          expect(Token).to receive(:find_each).and_yield(double('token', active?: false, value: 'some token value'))
          expect(Secure).to receive(:compare).with('some token value', 'some token value').and_return(true)
          expect(controller).to receive(:render_new_sessions_path_with_expired_token_message)
          expect { get :show, params: { id: 'some token value' } }.to raise_error { ActionView::MissingTemplate }
        end
      end
    end

    context 'token usage' do
      before { PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk') }
      let!(:token) { create(:token) }

      it 'token gets spent after use' do
        expect { get :show, params: { id: token.value }; }.to change { Token.unspent.count }.by(-1)
      end
    end
  end

  describe 'GET unsupported_browser' do
    before do
      get :unsupported_browser, params: { id: 'my-token' }
    end

    it { expect(assigns(:token)).to eql 'my-token' }
    it { expect(response).to render_template :unsupported_browser }
  end
end
