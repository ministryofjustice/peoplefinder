require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  let(:valid_attributes) { attributes_for(:user) }
  let(:invalid_attributes) { { email: '#' } }
  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }

  before do
    authenticate_as admin_user
  end

  describe 'GET index' do
    it 'assigns all users as @users' do
      get :index
      expect(assigns(:users)).to include(user)
    end
  end

  describe 'GET show' do
    it 'assigns the requested user as @user' do
      get :show, id: user.to_param
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET new' do
    it 'assigns a new user as @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested user as @user' do
      get :edit, id: user.to_param
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, user: valid_attributes
        }.to change(User, :count).by(1)
      end

      it 'assigns a newly created user as @user' do
        post :create, user: valid_attributes
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it 'redirects to the index' do
        post :create, user: valid_attributes
        expect(response).to redirect_to(admin_users_path)
      end

      it 'shows a success message' do
        post :create, user: valid_attributes
        expect(flash[:notice]).to match(/created/)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved user as @user' do
        post :create, user: invalid_attributes
        expect(assigns(:user)).to be_a_new(User)
      end

      it 're-renders the new template' do
        post :create, user: invalid_attributes
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_attributes) {
        attributes_for(:user)
      }

      it 'updates the requested user' do
        put :update, id: user.to_param, user: new_attributes
        user.reload
        new_attributes.each do |key, value|
          expect(user.send(key)).to eql(value)
        end
      end

      it 'assigns the requested user as @user' do
        put :update, id: user.to_param, user: valid_attributes
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the index' do
        put :update, id: user.to_param, user: valid_attributes
        expect(response).to redirect_to(admin_users_path)
      end

      it 'shows a success message' do
        put :update, id: user.to_param, user: valid_attributes
        expect(flash[:notice]).to match(/updated/)
      end
    end

    describe 'with invalid params' do
      it 'assigns the user as @user' do
        put :update, id: user.to_param, user: invalid_attributes
        expect(assigns(:user)).to eq(user)
      end

      it 're-renders the edit template' do
        put :update, id: user.to_param, user: invalid_attributes
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:user) { create(:user) }

    it 'destroys the requested user' do
      expect {
        delete :destroy, id: user.to_param
      }.to change(User, :count).by(-1)
    end

    it 'does not destroy the current user' do
      expect {
        delete :destroy, id: admin_user.to_param
      }.not_to change(User, :count)
    end

    it 'redirects to the users list' do
      delete :destroy, id: user.to_param
      expect(response).to redirect_to(admin_users_path)
    end

    it 'shows a success message' do
      delete :destroy, id: user.to_param
      expect(flash[:notice]).to match(/deleted/)
    end
  end
end
