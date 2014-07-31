require 'rails_helper'

RSpec.describe PasswordsController, :type => :controller do
  describe "GET show" do
    describe "with a valid token" do
      let(:user) { create(:user).tap { |u| u.set_password_reset_token! } }

      it "should assign the user" do
        get :show, { token: user.token } 
        expect(assigns(:user)).to eql(user)
      end
    end

    describe "with an invalid token" do
      it "should redirect to the new password page" do
        get :show, { token: 'INVALID' } 
        expect(response).to redirect_to(new_passwords_path)
      end
    end
  end

  describe "POST create" do
    let(:user) { create(:user) }

    describe "with a valid email address" do
      it "should set the user's reset token" do
        old_token = user.token
        post :create, { email: user.email }
        user.reload
        expect(user.token).not_to be_nil
        expect(user.token).not_to eql(old_token)
      end

      it "should redirect to the new password page" do
        post :create, { email: user.email }
        expect(response).to redirect_to(new_passwords_path)
      end
    end

    describe "with an invalid email address" do
      it "should render the new template" do
        post :create, { email: 'invalid@example.com' }
        expect(response).to render_template('new')
      end
    end
  end

  describe "PATCH update" do
    let(:password) { generate(:password) }

    describe "with an invalid token" do
      it "should redirect to the new password page" do
        patch :update, {
          token: "INVALID",
          user: {
            password: password,
            password_confirmation: password
          }
        }

        expect(response).to redirect_to(new_passwords_path)
      end
    end

    describe "with a valid token" do
      let(:user) { create(:user).tap { |u| u.set_password_reset_token! } }

      describe "with a valid password" do
        before do
          patch :update, {
            token: user.token,
            user: {
              password: password,
              password_confirmation: password
            }
          }
        end

        it "should update the user's password" do
          user.reload
          expect(user.authenticate(password)).to eql(user)
        end

        it "should redirect to the login page" do
          expect(response).to redirect_to(new_sessions_path)
        end
      end

      describe "with a mismatching password confirmation" do
        before do
          patch :update, {
            token: user.token,
            user: {
              password: password,
              password_confirmation: generate(:password)
            }
          }
        end

        it "should not update the user's password" do
          user.reload
          expect(user.authenticate(password)).to be_falsey
        end

        it "should re-render the show template" do
          expect(response).to render_template('show')
        end
      end
    end
  end
end
