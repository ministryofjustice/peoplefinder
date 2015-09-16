require 'rails_helper'

describe TokensController, type: :controller do
  describe 'GET show' do
    context 'securly verifies that a token is valid and active' do
      describe 'avoiding a method with differning repsonse times for valid and invalid tokens' do
        it 'does not use Token.where(value: param[:id]).first' do
          expect(Token).not_to receive(:where)
          get :show, id: 'some token value'
        end
      end

      describe 'using a method that takes a constant time regardless of the validity of the token' do
        it 'loops over a block of tokens and finds the first match using Secure.compare' do
          expect(Token).to receive(:find_each).and_yield(double('token', value: 'some token value'))
          expect(Secure).to receive(:compare).with('some token value', 'some token value').and_return(true)
          expect(controller).to receive(:verify_active_token).and_return(double.as_null_object)
          expect{ get :show, id: 'some token value' }.to raise_error{ ActionView::MissingTemplate }
        end
      end
    end

    context 'token usage' do
      before { PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk') }
      let!(:token) { create(:token) }

      it 'token gets removed after use' do
        expect { get :show, id: token.value; }.to change{ Token.count }.by(-1)
      end
    end
  end
end

