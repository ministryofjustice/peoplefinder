require 'rails_helper'

RSpec.describe AgreementsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:valid_attributes) {
      attributes_for(:agreement).merge(manager_email: 'manager@digital.justice.gov.uk')
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
        expect(response).to redirect_to(assigns(:agreement))
      end
    end

    describe "with invalid params" do
      it "it does not save the agreement" do
        post :create, { agreement: {} }
        expect(assigns(:agreement)).to be_new_record
      end

      it "renders the 'new' template" do
        post :create, { agreement: {} }
        expect(response).to render_template('new')
      end
    end
  end
end
