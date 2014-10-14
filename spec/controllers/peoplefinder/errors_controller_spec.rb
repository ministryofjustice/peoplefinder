require 'rails_helper'

RSpec.describe Peoplefinder::ErrorsController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  describe 'GET file_not_found' do
    it 'renders the file not found layout' do
      get :file_not_found
      expect(response).to render_template('file_not_found')
    end
  end

  describe 'GET unprocessable' do
    it 'returns http success' do
      get :unprocessable
      expect(response).to render_template('unprocessable')
    end
  end

  describe 'GET internal_server_error' do
    it 'returns http success' do
      get :internal_server_error
      expect(response).to render_template('internal_server_error')
    end
  end
end
