require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  include PermittedDomainHelper

  it_behaves_like 'user_agent_helpable'

  before do
    mock_logged_in_user
  end

  describe 'GET show' do

    context 'with supported browser' do
      before do
        allow_any_instance_of(described_class).to receive(:supported_browser?).and_return true
      end

      context 'when there is no top-level group' do
        it 'redirects to the new group page' do
          get :show
          expect(response).to redirect_to(new_group_path)
        end

        it 'tells the user to create a top-level group' do
          get :show
          expect(flash[:notice]).to have_text('create a top-level group')
        end
      end

      context 'when there is a top-level group' do
        before { create(:department) }

        it 'renders the show template' do
          get :show
          expect(response).to render_template('show')
        end

        it 'assigns the group to the top_level_group' do
          get :show
          expect(assigns(:group).name).to eql('Ministry of Justice')
        end
      end
    end

    context 'with unsupported browser' do
      before do
        allow_any_instance_of(described_class).to receive(:supported_browser?).and_return false
        get :show
      end

      it 'redirects to warning page' do
        expect(response).to redirect_to unsupported_browser_path
      end
    end
  end

  describe 'GET unsupported_browser_continue' do
    before do
      get :unsupported_browser_continue
    end

    it 'saves choice in session state' do
      expect(session[:continue_using_unsupported_browser]).to eql true
    end

    it 'redirects to show action' do
      is_expected.to redirect_to action: :show
    end
  end
end
