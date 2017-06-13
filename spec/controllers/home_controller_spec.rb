require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
  end

  it_behaves_like 'user_agent_helpable'

  describe 'GET show' do
    context 'when there is no top-level group' do
      before { get :show }

      it 'redirects to the new group page' do
        expect(response).to redirect_to(new_group_path)
      end

      it 'tells the user to create a top-level group' do
        expect(flash[:notice]).to have_text('create a top-level group')
      end
    end

    context 'when there is a top-level group' do
      before do
        create(:department)
        get :show
      end

      it '#can_add_person_here? returns true' do
        expect(controller.can_add_person_here?).to eql true
      end

      it 'renders the show template' do
        expect(response).to render_template('show')
      end

      it 'assigns the group to the top_level_group' do
        expect(assigns(:department).name).to eql('Ministry of Justice')
      end
    end
  end

end
