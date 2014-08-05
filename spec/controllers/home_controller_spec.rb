require 'rails_helper'

RSpec.describe HomeController, :type => :controller do
  before do
    mock_logged_in_user
  end

  describe 'GET show' do
    context 'when there is no top-level group' do
      it 'should redirect to the new group page' do
        get :show
        expect(response).to redirect_to(new_group_path)
      end

      it 'should tell the user to create a top-level group' do
        get :show
        expect(flash[:notice]).to have_text('create a top-level group')
      end
    end

    context 'when there is a top-level group' do
      before { create(:group, name: 'Ministry of Justice', parent: nil) }

      it 'should render the show template' do
        get :show
        expect(response).to render_template('show')
      end

      it 'should assign the group to the top_level_group' do
        get :show
        expect(assigns(:group).name).to eql('Ministry of Justice')
      end
    end
  end
end