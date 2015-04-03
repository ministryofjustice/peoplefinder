require 'rails_helper'
RSpec.describe Metrics::ProfilesController, type: :controller do
  let(:parsed_body) { JSON.parse(response.body) }

  describe 'GET index' do
    let(:number_of_profiles) { 7 }
    before do
      create_list(:person, number_of_profiles)
      get :index
    end

    it 'returns JSON for total number of profiles' do
      expected = {
        'item' => [
          {
            'value' => number_of_profiles
          }
        ]
      }

      expect(parsed_body).to eq(expected)
    end

    it 'returns 200 OK' do
      expect(response).to be_ok
    end
  end
end
