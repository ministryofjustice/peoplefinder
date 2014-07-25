require 'rails_helper'

RSpec.describe ObjectivesController, :type => :controller do

  before do
    mock_logged_in_user
  end

  describe 'GET index' do

    let(:agreement) {
      create(:agreement, jobholder: current_test_user)
    }

    it 'should load an agreement to scope user to' do
      relation = Agreement.all
      allow(relation).to receive(:[]).and_return( [build_stubbed(:agreement)] )

      expect(Agreement).to receive(:editable_by).with(current_test_user).once.and_return(relation)
      get :index, agreement_id: agreement.id
    end

  end

end
