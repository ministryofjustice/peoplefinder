require 'rails_helper'

RSpec.describe PersonDeletionRequestController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
  end

  let(:person) { create(:person) }

  describe 'GET new' do
    it 'assigns the requested person as @person' do
      get :new, person_id: person.to_param
      expect(assigns(:person)).to eq(person)
    end
  end

  describe 'POST create' do
    it 'redirects to the profile page' do
      post :create, person_id: person.to_param
      expect(response).to redirect_to(person_path(person))
    end

    it 'invokes the mailer to send an email now' do
      mock_mailer = double("PersonDeletionRequestMailer")

      expect(PersonDeletionRequestMailer).to receive(:deletion_request).
        with(
          reporter: current_user,
          person: person,
          note: 'This is a note'
        ).and_return(mock_mailer)

      expect(mock_mailer).to receive(:deliver_now)

      post :create, person_id: person.to_param, note: 'This is a note'
    end
  end

end
