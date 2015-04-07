require 'rails_helper'
RSpec.describe Metrics::CompletionsController, type: :controller do
  let(:parsed_body) { JSON.parse(response.body) }

  describe 'GET index' do
    it 'returns JSON for the overall completion score' do
      allow(Person).to receive(:overall_completion).and_return(37)
      expected = {
        'item' => 37,
        'min' => { 'value' => 0 },
        'max' => { 'value' => 100 }
      }
      get :index
      expect(parsed_body).to eq(expected)
    end

    it 'returns 200 OK' do
      get :index
      expect(response).to be_ok
    end
  end
end
