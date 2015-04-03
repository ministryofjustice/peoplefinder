require 'rails_helper'

RSpec.describe Api::PeopleController, type: :controller do
  routes { Engine.routes }

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:person)
  }

  let(:invalid_attributes) {
    { surname: '' }
  }

  let(:valid_attributes_with_image) {
    attributes_for(:person).merge(image: File.open(sample_image))
  }

  let!(:group) { create(:group) }

  describe 'GET show' do
    subject { create(:person, valid_attributes) }

    context 'with valid auth token' do
      let(:token) { create(:token) }

      before do
        request.headers['AUTHORIZATION'] = token.value
        get :show, id: subject.to_param
      end

      it 'assigns the requested person as @person' do
        expect(assigns(:person)).to eq(subject)
      end

      it 'returns a JSON representation of the person' do
        expect(JSON.parse(response.body)).to eq(JSON.parse(subject.to_json))
      end
    end

    context 'without valid auth token' do
      before do
        request.headers['AUTHORIZATION'] = 'xxxxxxxx'
        get :show, id: subject.to_param
      end

      it 'returns status 401' do
        expect(response.status).to eq(401)
      end

      it 'returns a JSON error' do
        expect(response.body).to match(/unauthorized/i)
      end
    end
  end
end
