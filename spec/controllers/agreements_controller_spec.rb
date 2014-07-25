require 'rails_helper'

RSpec.describe AgreementsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:valid_attributes) {
    attributes_for(:agreement).merge(jobholder: current_test_user)
  }

  describe 'GET new' do
    it 'assigns the jobholder' do
      get :new
      expect(assigns(:agreement).jobholder).to be_present
    end

    it 'inits the budgetary_responsibilities' do
      get :new
      expect(assigns(:agreement).budgetary_responsibilities).to be_present
    end

    it 'inits the objectives' do
      get :new
      expect(assigns(:agreement).budgetary_responsibilities).to be_present
    end

    it 'renders the "new" template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    describe "with valid params" do
      it "redirects to the created agreement" do
        post :create, { agreement: valid_attributes }
        expect(response).to redirect_to('/')
      end
    end


    describe "with invalid params" do
      it "it does not save the agreement" do
        post :create, { agreement: {} }
        expect(assigns(:agreement)).to be_new_record
      end


      it "sets a flash massage" do
        post :create, { agreement: valid_attributes }
        expect(request.flash[:notice]).to match(/success/)
      end
    end
  end

  describe 'GET edit' do
    context 'allowed to view the agreement' do
      let(:agreement) { create(:agreement, jobholder_email: current_test_user.email) }

      it 'assigns the agreement' do
        get :edit, id: agreement.to_param
        expect(assigns(:agreement)).to eql(agreement)
      end

      it 'renders the edit template' do
        get :edit, id: agreement.to_param
        expect(assigns(:agreement)).to eql(agreement)
      end
    end

    context 'not allowed to view the agreement' do
      let(:agreement) { create(:agreement, jobholder_email: 'notme', manager_email: 'noryou') }

      it 'raises an error' do
        expect { get :edit, id: agreement.to_param
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'budgetary responsibilities and objectives' do
      let(:agreement) { create(:agreement, valid_attributes) }

      context 'when they have been pre-defined' do
        before do
          agreement.update_attributes!(headcount_responsibilities: {},
            budgetary_responsibilities: [],
            objectives: []
          )
        end

        it 'has previously set the objectives and budgetary_responsibilities' do
          get :edit, id: agreement.to_param

          expect(assigns(:agreement).budgetary_responsibilities.all).to be_empty
          expect(assigns(:agreement).objectives.all).to be_empty
        end
      end

      context 'when they have not been pre-defined' do
        it 'has not previously set the objectives and budgetary_responsibilities' do
          get :edit, id: agreement.to_param

          expect(assigns(:agreement).budgetary_responsibilities.length).to eql(1)
          expect(assigns(:agreement).budgetary_responsibilities.first).to be_instance_of(BudgetaryResponsibility)
          expect(assigns(:agreement).objectives.count).to eql(1)
          expect(assigns[:agreement].objectives.first).to be_instance_of(Objective)
        end
      end
    end
  end

  describe 'PUT update' do
    let(:agreement) { create(:agreement, jobholder: current_test_user) }

    it "redirects to the dashboard" do
      put :update, { id: agreement.id, agreement: valid_attributes }
      expect(response).to redirect_to('/')
    end
  end

  describe 'GET index' do
    it 'should call editable_by current_user' do
      expect(Agreement).to receive(:editable_by).with(current_test_user).once.and_return(double('ActiveRecord::Relation'))
      get :index
    end
  end
end
