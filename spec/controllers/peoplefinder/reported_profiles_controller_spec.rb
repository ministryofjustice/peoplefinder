require 'rails_helper'

RSpec.describe Peoplefinder::ReportedProfilesController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  let(:person) { create(:person, email: 'someone.else@digital.justice.gov.uk') }

  describe 'GET new' do
    before { get :new, person_id: person.id }

    it 'assigns the person' do
      expect(assigns(:person)).to eql(person)
    end

    it 'assigns a new reported profile' do
      expect(assigns(:reported_profile)).to be_new_record
    end

    it 'renders the new template' do
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      before do
        person.groups << create(:group)
        post :create, person_id: person.id, reported_profile: valid_params
      end

      it 'sets the notifier' do
        expect(assigns(:reported_profile).notifier).to eql(current_user)
      end

      it 'sets the recipient email' do
        expect(assigns(:reported_profile).recipient_email).to eql(person.support_email)
      end

      it 'sets the subject' do
        expect(assigns(:reported_profile).subject).to eql(person)
      end

      it 'redirects to the person\'s profile page' do
        expect(response).to redirect_to(person_path(person))
      end

      it 'sets a flash message' do
        expect(flash[:notice]).to have_text('Your message has been sent')
      end
    end

    context 'with invalid params' do
      before do
        post :create, person_id: person.id, reported_profile: invalid_params
      end

      it 'renders the new template' do
        expect(response).to render_template('new')
      end
    end
  end

  def valid_params
    {
      reason_for_reporting: 'Duplicate',
      message: 'Some stuff'
    }
  end

  def invalid_params
    {
      reason_for_reporting: ''
    }
  end
end
