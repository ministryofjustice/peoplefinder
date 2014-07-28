require 'rails_helper'

RSpec.describe ResponsibilitiesAgreementsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:valid_attributes) {
    attributes_for(:agreement).merge(staff_member: current_test_user)
  }

  describe 'GET edit' do
    context 'allowed to view the agreement' do
      let(:agreement) { create(:agreement, staff_member: current_test_user) }

      it 'assigns the agreement' do
        get :edit, id: agreement.to_param
        expect(assigns(:responsibilities_agreement)).to eql(agreement)
      end

      it 'renders the edit template' do
        get :edit, id: agreement.to_param
        expect(assigns(:responsibilities_agreement)).to eql(agreement)
      end
    end

    context 'not allowed to view the agreement' do
      let(:agreement) { create(:agreement) }

      it 'raises an error' do
        expect { get :edit, id: agreement.to_param
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'budgetary responsibilities' do
      let(:agreement) { create(:agreement, valid_attributes) }

      context 'when they have been pre-defined' do
        before do
          agreement.update_attributes!(headcount_responsibilities: {},
            budgetary_responsibilities: []
          )
        end

        it 'has previously set the budgetary_responsibilities' do
          get :edit, id: agreement.to_param

          expect(assigns(:responsibilities_agreement).budgetary_responsibilities.all).to be_empty
        end
      end

      context 'when they have not been pre-defined' do
        it 'has not previously set the budgetary_responsibilities' do
          get :edit, id: agreement.to_param

          expect(assigns(:responsibilities_agreement).budgetary_responsibilities.length).to eql(1)
          expect(assigns(:responsibilities_agreement).budgetary_responsibilities.first).to be_instance_of(BudgetaryResponsibility)
        end
      end
    end
  end

  describe 'PUT update' do
    let(:agreement) { create(:agreement, staff_member: current_test_user) }

    it "redirects to the dashboard" do
      put :update, { id: agreement.id, responsibilities_agreement: valid_attributes }
      expect(response).to redirect_to('/')
    end
  end
end
