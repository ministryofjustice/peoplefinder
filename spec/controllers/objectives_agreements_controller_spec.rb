require 'rails_helper'

RSpec.describe ObjectivesAgreementsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:valid_attributes) {
    attributes_for(:agreement).merge(jobholder: current_test_user)
  }

  describe 'GET edit' do
    context 'allowed to view the agreement' do
      let(:agreement) { create(:agreement, jobholder: current_test_user) }

      it 'assigns the agreement' do
        get :edit, id: agreement.to_param
        expect(assigns(:objectives_agreement)).to eql(agreement)
      end

      it 'renders the edit template' do
        get :edit, id: agreement.to_param
        expect(assigns(:objectives_agreement)).to eql(agreement)
      end
    end

    context 'not allowed to view the agreement' do
      let(:agreement) { create(:agreement) }

      it 'raises an error' do
        expect { get :edit, id: agreement.to_param
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PUT update' do
    let(:agreement) { create(:agreement, jobholder: current_test_user) }

    it "redirects to the dashboard" do
      put :update, { id: agreement.id, objectives_agreement: valid_attributes }
      expect(response).to redirect_to('/')
    end
  end
end
