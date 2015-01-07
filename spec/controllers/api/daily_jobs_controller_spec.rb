require 'rails_helper'
RSpec.describe Api::DailyJobsController, type: :controller do
  before do
    ENV['API_KEY'] = 'CorrectKey'
  end

  let(:parsed_body) { JSON.parse(response.body) }

  describe 'POST create' do
    context 'with correct API key' do
      it 'runs the RemindersJob' do
        expect(RemindersJob).to receive(:perform_later)
        post :create, key: 'CorrectKey'
      end

      it 'returns 200 OK' do
        post :create, key: 'CorrectKey'
        expect(response).to be_ok
      end

      it 'returns JSON with status ok' do
        post :create, key: 'CorrectKey'
        expect(parsed_body['status']).to eq('ok')
      end
    end

    context 'with incorrect API key' do
      it 'does not run the RemindersJob' do
        expect(RemindersJob).not_to receive(:perform_later)
        post :create, key: 'WrongKey'
      end

      it 'returns 403 forbidden' do
        post :create, key: 'WrongKey'
        expect(response).to be_forbidden
      end

      it 'returns JSON with status forbidden' do
        post :create, key: 'WrongKey'
        expect(parsed_body['status']).to eq('forbidden')
      end
    end
  end
end
