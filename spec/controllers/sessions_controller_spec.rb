require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'concerns', 'shared_examples_for_session_person_creator.rb')

RSpec.describe SessionsController, type: :controller do
  include PermittedDomainHelper

  it_behaves_like 'session_person_creatable'

  let!(:person) { create(:person, given_name: 'John', surname: 'Doe', email: 'john.doe@digital.justice.gov.uk') }
  let!(:o365_person) { create(:person, given_name: 'John', surname: 'Bloggs', email: 'john.bloggs@justice.gov.uk') }

  let(:john_bloggs_azure_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'azure_oauth2',
      info: {
        email: o365_person.email,
        first_name: o365_person.given_name,
        last_name: o365_person.surname,
        name: o365_person.name
      }
    )
  end

  let(:john_doe_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'gplus',
      info: {
        email: 'john.doe@digital.justice.gov.uk',
        first_name: 'John',
        last_name: 'Doe',
        name: 'John Doe'
      }
    )
  end

  let(:john_doe2_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'gplus',
      info: {
        email: 'john.doe2@digital.justice.gov.uk',
        first_name: 'John',
        last_name: 'Doe',
        name: 'John Doe'
      }
    )
  end

  let(:fred_bloggs_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'gplus',
      info: {
        email: 'fred.bloggs@digital.justice.gov.uk',
        first_name: 'Fred',
        last_name: 'Bloggs',
        name: 'Fred Bloggs'
      }
    )
  end

  describe 'POST create' do

    context 'with azure omniauth' do
      context 'when person already exists' do
        before do
          request.env["omniauth.auth"] = john_bloggs_azure_omniauth_hash
        end

        it 'does not create a user' do
          expect { post :create }.to_not change Person, :count
        end

        it 'redirects to the person\'s profiles page' do
          post :create
          expect(response).to redirect_to person_path(o365_person, prompt: 'profile')
        end
      end
    end

    context 'with gplus omniauth' do
      context 'when person already exists' do
        before do
          request.env["omniauth.auth"] = john_doe_omniauth_hash
        end

        it 'does not create a user' do
          expect { post :create }.to_not change Person, :count
        end

        it 'redirects to the person\'s profiles page' do
          post :create
          expect(response).to redirect_to person_path(person, prompt: 'profile')
        end
      end

      context 'when person does not exist' do
        before do
          request.env["omniauth.auth"] = fred_bloggs_omniauth_hash
        end

        it 'creates the new person' do
          expect { post :create }.to change Person, :count
        end

        it 'creates person from oauth hash' do
          Timecop.freeze(Date.today - 1) { post :create }
          person = Person.first
          expect(person.email).to eql fred_bloggs_omniauth_hash['info']['email']
          expect(person.given_name).to eql fred_bloggs_omniauth_hash['info']['first_name']
          expect(person.surname).to eql fred_bloggs_omniauth_hash['info']['last_name']
        end

        it 'redirects to the person\'s profile edit page, ignoring desired path' do
          request.session[:desired_path] = new_group_path
          post :create
          expect(response).to redirect_to edit_person_path(Person.find_by(email: 'fred.bloggs@digital.justice.gov.uk'), page_title: "Create profile")
        end
      end

      context 'when new person has namesakes' do
        before do
          request.env["omniauth.auth"] = john_doe2_omniauth_hash
        end

        it 'renders confirmation page' do
          post :create
          expect(response).to render_template(:person_confirm)
        end

        it 'does not create the new person' do
          expect { post :create }.to_not change Person, :count
        end
      end

      context 'using invalid omniauth hash' do
        let(:invalid_omniauth_hash) do
          OmniAuth::AuthHash.new(
            provider: 'gplus',
            info: {
              email: 'rogue.user@example.com',
              first_name: 'John',
              last_name: 'Doe',
              name: 'John Doe'
            }
          )
        end

        before do
          request.env["omniauth.auth"] = invalid_omniauth_hash
        end

        it 'renders failed page' do
          post :create
          expect(response).to render_template :failed
        end

        it 'does not create the new person' do
          expect { post :create }.to_not change Person, :count
        end
      end
    end
  end

  describe 'POST create_person' do
    let(:person_params) do
      {
        person: {
          email: 'fred.bloggs@digital.justice.gov.uk',
          given_name: 'Fred',
          surname: 'Bloggs'
        }
      }
    end

    it 'creates the new person' do
      expect { post :create_person, person_params }.to change Person, :count
    end

    it 'redirects to the person\'s profile edit page, ignoring desired path' do
      request.session[:desired_path] = '/search'
      post :create_person, person_params
      expect(response).to redirect_to edit_person_path(Person.find_by(email: 'fred.bloggs@digital.justice.gov.uk'), page_title: "Create profile")
    end
  end
end
