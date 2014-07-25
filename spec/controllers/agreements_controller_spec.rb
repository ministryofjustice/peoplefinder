require 'rails_helper'

RSpec.describe AgreementsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  describe 'GET index' do
    it 'should call editable_by current_user' do
      expect(Agreement).to receive(:editable_by).with(current_test_user).once.and_return(double('ActiveRecord::Relation'))
      get :index
    end
  end
end
