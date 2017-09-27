require 'rails_helper'

RSpec.describe PersonEmailController, type: :controller do
  include PermittedDomainHelper

  let(:valid_attributes) { attributes_for(:person) }
  let(:invalid_attributes) { { surname: '' } }
  let(:new_email) { 'my-new-email@digital.justice.gov.uk' }
  let(:token) { create(:token, user_email: new_email, spent: true) }
  let(:oauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'ditsso_internal',
      info: {
        email: new_email,
        first_name: 'John',
        last_name: 'Doe',
        name: 'John Doe'
      }
    )
  end

  describe 'GET edit' do
    let(:person) { create(:person, valid_attributes) }

    shared_examples 'renders edit template' do
      it { expect(response).to render_template :edit }

      it 'assigns the requested person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 'assigns new email as @new_email' do
        expect(assigns(:new_email)).to eq(new_email)
      end

      it 'assigns existing primary email as @new_secondary_email' do
        expect(assigns(:new_secondary_email)).to eq(person.email)
      end
    end

    context 'without authentication' do
      let(:request) { get :edit, person_id: person.to_param }

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    context 'with logged in user' do
      before do
        controller.singleton_class.class_eval do
          def current_user
            Person.first
          end
          helper_method :current_user
        end
      end

      let(:request) { get :edit, person_id: person.to_param }

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    context 'with token authentication' do
      context 'with a valid token' do
        before do
          get :edit, person_id: person.to_param, token_value: token.value
        end

        include_examples 'renders edit template'
      end

      context 'with an expired token' do
        let(:token) { create(:token, user_email: new_email, spent: true, created_at: (Token::DEFAULT_EXTRA_EXPIRY_PERIOD+1).ago) }
        let(:request) { get :edit, person_id: person.to_param, token_value: token.value }

        it 'raises routing error for handling by server as Not Found' do
          expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
        end
      end
    end

    context 'with oauth authentication' do
      before do
        get :edit, person_id: person.to_param, oauth_hash: oauth_hash
      end

      include_examples 'renders edit template'
    end
  end

  describe 'PUT update' do
    let(:person) { create(:person, given_name: "John", surname: "Doe", email: 'john.doe@digital.justice.gov.uk') }
    let(:new_attributes) { { email: 'john.doe2@digital.justice.gov.uk', secondary_email: 'john.doe@digital.justice.gov.uk', pager_number: '0100' } }

    context 'without authentication' do
      subject(:request) do
        put :update, person_id: person.to_param, person: new_attributes
      end

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    shared_examples 'updates the person' do
      it 'assigns person' do
        subject
        expect(assigns(:person)).to eql person
      end

      it 'updates email and secondary email only' do
        subject
        person.reload
        expect(person.email).to eql new_attributes[:email]
        expect(person.secondary_email).to eql new_attributes[:secondary_email]
        expect(person.pager_number).not_to eql new_attributes[:pager_number]
      end

      it 'redirects to profile page, ignoring desired path' do
        request.session[:desired_path] = new_group_path
        is_expected.to redirect_to person_path(person, prompt: 'profile')
      end

      it 'sets a flash message' do
        subject
        expect(flash[:notice]).to include("Your main email has been updated to #{new_attributes[:email]}")
      end
    end

    context 'with a valid token' do
      subject { put :update, person_id: person.to_param, person: new_attributes, token_value: token.value }

      include_examples 'updates the person'
    end

    context 'with an expired token' do
      let(:token) { create(:token, user_email: new_email, spent: true, created_at: (Token::DEFAULT_EXTRA_EXPIRY_PERIOD+1).ago) }
      let(:request) { put :update, person_id: person.to_param, person: new_attributes, token_value: token.value }

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    context 'with oauth authentication' do
      subject { put :update, person_id: person.to_param, person: new_attributes, oauth_hash: oauth_hash }

      include_examples 'updates the person'
    end

  end

end
